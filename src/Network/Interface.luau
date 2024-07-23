-- Module

local ClientEvent = {}
local ServerEvent = {}
local ClientFunction = {}
local ServerFunction = {}

-- Variables

local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")

local Objects = require(script.Parent.Parent.Objects)
local Types = require(script.Parent.Parent.Types)

local Server = require(script.Parent.Server)
local Client = require(script.Parent.Client)
local Identifier = require(script.Parent.Identifier)

local Packages = script.Parent.Parent.Parent
local Promise = require(Packages.promise)
local Ratelimit = require(Packages.ratelimit)

local ReservedNames = {}

local RunContext = if RunService:IsServer() then "Server" else "Client"

local Indexes = {
	Event = {
		{ __index = ClientEvent },
		{ __index = ServerEvent },
	},
	Function = {
		{ __index = ClientFunction },
		{ __index = ServerFunction },
	},
}

local Remotes = {
	Server = Server,
	Client = Client,
}

-- Functions

local function new(kind: "Event" | "Function", name: string, reliable: boolean?, bypass: boolean?): Types.Promise<any>
	return Promise.new(function(resolve, reject)
		if not bypass and table.find(ReservedNames, name) then
			reject("[Lumin] Cannot use a name that is reserved by the framework itself")
		end

		local self = setmetatable({}, if RunService:IsClient() then Indexes[kind][1] else Indexes[kind][2])

		if Objects.Networks[kind][name] then
			resolve(Objects.Networks[kind][name])
		else
			Objects.Networks[kind][name] = self
		end

		local IdentifierName = `{name}_{kind}`

		if Identifier.Exists(IdentifierName) then
			reject("[Lumin] Cannot use same event/function name multiple times")
		end

		reliable = reliable or reliable == nil

		self.Reliable = reliable
		self._Ratelimit = nil
		self._CallOverflow = nil
		self._Identifier = Identifier.Shared(IdentifierName):expect()

		self._Fire = if reliable then Remotes[RunContext].SendReliable else Remotes[RunContext].SendUnreliable
		self._FireNow = if reliable then Remotes[RunContext].SendReliableNow else Remotes[RunContext].SendUnreliableNow

		resolve(Objects.Networks[kind][name])
	end)
end

function ClientEvent:Fire(...: any)
	self._Fire(self._Identifier, table.pack(...))
end

function ClientEvent:FireNow(...: any)
	self._FireNow(self._Identifier, table.pack(...))
end

function ClientEvent:Listen(func: (...any) -> ())
	assert(func, "[Lumin] Must provide a listener")
	Client.Listen(self._Identifier, function(args)
		func(table.unpack(args))
	end)
end

function ClientFunction:InvokeAsync(...: any): Types.Promise<...any>
	local Packed = { ... }
	return Promise.new(function(resolve)
		resolve(
			table.unpack(
				Client.SendReliableCallAsync(self._Identifier, table.pack(Identifier.Unique(), table.unpack(Packed)))
			)
		)
	end)
end

function ServerEvent:Fire(recipients: Player | { Player }, ...: any)
	if type(recipients) == "table" then
		for _, player in recipients do
			self._Fire(player, self._Identifier, table.pack(...))
		end
		return
	end
	self._Fire(recipients, self._Identifier, table.pack(...))
end

function ServerEvent:FireNow(recipients: Player | { Player }, ...: any)
	if type(recipients) == "table" then
		for _, player in recipients do
			self._FireNow(player, self._Identifier, table.pack(...))
		end
		return
	end
	self._FireNow(recipients, self._Identifier, table.pack(...))
end

function ServerEvent:FireAll(...: any)
	for _, player in PlayerService:GetPlayers() do
		self._Fire(player, self._Identifier, table.pack(...))
	end
end

function ServerEvent:FireExcept(except: Player | { Player }, ...: any)
	if type(except) == "table" then
		for _, player in PlayerService:GetPlayers() do
			if table.find(except, player) then
				continue
			end
			self._Fire(player, self._Identifier, table.pack(...))
		end
		return
	end

	for _, player in PlayerService:GetPlayers() do
		if player == except then
			continue
		end
		self._Fire(player, self._Identifier, table.pack(...))
	end
end

function ServerEvent:FireFilter(filter: (Player) -> boolean, ...: any)
	for _, player in PlayerService:GetPlayers() do
		if filter(player) then
			self._Fire(player, self._Identifier, table.pack(...))
		end
	end
end

function ServerEvent:Listen(func: (sender: Player, ...unknown) -> (), typeValidationArgs: { string }?)
	assert(func, "[Lumin] Must provide a listener")
	Server.Listen(self._Identifier, function(player, args)
		if (self._Ratelimit and self._InvokeOverflow) and not self._Ratelimit(player) then
			self._InvokeOverflow(player)
			return
		end

		if typeValidationArgs then
			for index, value in args do
				if typeof(value) ~= typeValidationArgs[index] then
					error(`[Lumin] Argument #{index} does not have the type '{typeValidationArgs[index]}'`)
				end
			end
		end

		func(player, table.unpack(args))
	end)
end

function ServerEvent:SetRateLimit(
	maxCalls: number,
	resetInterval: number?,
	fireOverflowCallback: (sender: Player) -> ()?
)
	if maxCalls <= -1 then
		self._Ratelimit = nil
		self._CallOverflow = nil
	end

	if not (resetInterval and fireOverflowCallback) then
		return
	end

	self._Ratelimit = Ratelimit(maxCalls, resetInterval or 1) :: any
	self._CallOverflow = fireOverflowCallback :: any
end

function ServerFunction:SetRateLimit(
	maxCalls: number,
	resetInterval: number?,
	callOverflowCallback: (sender: Player) -> ()?
)
	if maxCalls <= -1 then
		self._Ratelimit = nil
		self._CallOverflow = nil
	end

	if not (resetInterval and callOverflowCallback) then
		return
	end

	self._Ratelimit = Ratelimit(maxCalls, resetInterval or 1) :: any
	self._InvokeOverflow = callOverflowCallback :: any
end

function ServerFunction:OnInvoke(
	callback: (sender: Player, ...unknown) -> (unknown, ...any),
	typeValidationArgs: { string }?
)
	assert(callback, "Must provide a callback")
	Server.Listen(self._Identifier, function(player, args)
		if (self._Ratelimit and self._InvokeOverflow) and not self._Ratelimit(player) then
			self._InvokeOverflow(player)
			return
		end

		local callId = table.remove(args, 1)

		if type(callId) ~= "string" then
			return
		end

		if typeValidationArgs then
			for index, value in args do
				if typeof(value) ~= typeValidationArgs[index] then
					error(`[Lumin] Argument #{index} does not have the type '{typeValidationArgs[index]}'`)
				end
			end
		end

		task.spawn(function(player: Player, callId: string, ...: any)
			Server.SendReliableCallReturn(player, callId, table.pack(callback(player, ...)))
		end, player, callId, table.unpack(args))
	end)
end

return {
	new = new,
}
