-- // Package

local ClientEvent = {}
local ServerEvent = {}
local ClientFunction = {}
local ServerFunction = {}

-- // Variables

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local RunContext = if RunService:IsClient() then "Client" else "Server"
local Indexes = {
	Event = {
		{__index = ClientEvent},
		{__index = ServerEvent},
	},
	Function = {
		{__index = ClientFunction},
		{__index = ServerFunction},
	}
}

local Future = require(script.Parent.Parent.future)
local Ratelimit = require(script.Parent.Parent.ratelimit)
local Spawn = require(script.Parent.Parent.spawn)
local Red = require(script.Parent.Parent.red)
local Runtime = require(script.Parent.Runtime)
local Debugger = require(script.Parent.Debugger)

local RedIdentifier = Red.Identifier
local RedServerEvent = Red.Server
local RedClientEvent = Red.Client

local RedEvents = {
	Server = RedServerEvent,
	Client = RedClientEvent,
}

-- // Types

export type ServerFunction = {
	OnInvoke: (self: ServerFunction, callback: (sender: Player, ...unknown) -> (any, ...any), typeValidationArgs: {string}?) -> (),
	IsReliable: boolean,
}

export type ServerEvent = {
	Listen: (self: ServerEvent, func: (sender: Player, ...unknown) -> (), typeValidationArgs: {string}?) -> (),

	Fire: (self: ServerEvent, recipient: Player | {Player}, ...any) -> (),
	FireAll: (self: ServerEvent, ...any) -> (),
	FireExcept: (self: ServerEvent, except: Player | {Player}, ...any) -> (),
	FireFilter: (self: ServerEvent, filter: (Player) -> (boolean), ...any) -> (),

	SetRateLimit: (self: ServerEvent, maxCalls: number, resetInterval: number?, invokeOverflowCallback: (sender: Player) -> ()?) -> (),

	IsReliable: boolean,
}

export type ClientFunction = {
	InvokeAsync: (self: ClientFunction, ...any) -> (Future.Future<...any>),
	IsReliable: boolean,
}

export type ClientEvent = {
	Listen: (self: ClientEvent, func: (...any) -> ()) -> (),
	Fire: (self: ClientEvent, ...any) -> (),

	IsReliable: boolean,
}

-- // Functions

-- // Client

function ClientEvent:Fire(...: any)
	self._Fire(self._Identifier, table.pack(...))
end

function ClientEvent:Listen(func: (...any) -> ())
	assert(func, "Must provide a listener")
	RedClientEvent.SetListener(self._Identifier, function(args)
		func(table.unpack(args))
	end)
end

function ClientFunction:InvokeAsync(...: any): Future.Future<...any>
	return Future.new(function(...: any)
		return table.unpack(RedClientEvent.CallAsync(self._Identifier, table.pack(RedIdentifier.Unique(), ...)))
	end, ...)
end

-- // Server

function ServerEvent:Fire(recipients: Player | {Player}, ...: any)
	if type(recipients) == "table" then
		for _, player in recipients do
			self._Fire(player, self._Identifier, table.pack(...))
		end
		return
	end
	self._Fire(recipients, self._Identifier, table.pack(...))
end

function ServerEvent:FireAll(...: any)
	for _, player in PlayerService:GetPlayers() do
		self._Fire(player, self._Identifier, table.pack(...))
	end
end

function ServerEvent:FireExcept(except: Player | {Player}, ...: any)
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

function ServerEvent:FireFilter(filter: (Player) -> (boolean), ...: any)
	for _, player in PlayerService:GetPlayers() do
		if filter(player) then
			self._Fire(player, self._Identifier, table.pack(...))
		end
	end
end

function ServerEvent:Listen(func: (sender: Player, ...unknown) -> (), typeValidationArgs: {string}?)
	assert(func, "Must provide a listener")
	RedServerEvent.SetListener(self._Identifier, function(player, args)
		if (self._Ratelimit and self._InvokeOverflow) and not self._Ratelimit(player) then
			self._InvokeOverflow(player)
			return
		end
		
		if typeValidationArgs and not script.Parent:GetAttribute("IgnoreInvalidNetworkArgs") then
			for index, value in args do
				if typeof(value) ~= typeValidationArgs[index] then
					warn(`[Network] Argument #{index} does not have the type '{typeValidationArgs[index]}'`)
					return
				end
			end
		end

		func(player, table.unpack(args))
	end)
end

function ServerEvent:SetRateLimit(maxCalls: number, resetInterval: number?, invokeOverflowCallback: (sender: Player) -> ()?)
	if maxCalls <= -1 then
		self._Ratelimit = nil
		self._InvokeOverflow = nil
	end

	if not (resetInterval and invokeOverflowCallback) then
		return
	end

	self._Ratelimit = Ratelimit(maxCalls, resetInterval or 1) :: any
	self._InvokeOverflow = invokeOverflowCallback :: any
end

function ServerFunction:OnInvoke(callback: (sender: Player, ...unknown) -> (unknown, ...any), typeValidationArgs: {string}?)
	assert(callback, "Must provide a callback")
	RedServerEvent.SetListener(self._Identifier, function(player, args)
		if (self._Ratelimit and self._InvokeOverflow) and not self._Ratelimit(player) then
			self._InvokeOverflow(player)
			return
		end

		local callId = table.remove(args, 1)

		if type(callId) ~= "string" then
			return
		end

		if typeValidationArgs and not script.Parent:GetAttribute("IgnoreInvalidNetworkArgs") then
			for index, value in args do
				if typeof(value) ~= typeValidationArgs[index] then
					warn(`[Network] Argument #{index} does not have the type '{typeValidationArgs[index]}'`)
					return
				end
			end
		end

		Spawn(function(player: Player, callId: string, ...: any)
			RedServerEvent.SendCallReturn(player, callId, table.pack(callback(player, ...)))
		end, player, callId, table.unpack(args))
	end)
end

-- // Actions

table.freeze(ClientEvent)
table.freeze(ServerEvent)
table.freeze(ClientFunction)
table.freeze(ServerFunction)

return function(type: "Event" | "Function", name: string, reliable: boolean?): any
	assert(not RedIdentifier.Exists(`{name}_{type}`), "Cannot use same event/function name multiple times")
	reliable = if reliable == nil then true else reliable

	local self = setmetatable({}, if RunService:IsClient() then Indexes[type][1] else Indexes[type][2])

	self.IsReliable = reliable

	self._Ratelimit = nil
	self._InvokeOverflow = nil
	self._Identifier = RedIdentifier.Shared(`{name}_{type}`):Await()

	self._Fire = if reliable then 
		RedEvents[RunContext].SendReliableEvent
	else
		RedEvents[RunContext].SendUnreliableEvent

	if not Runtime.Objects.Network[type][name] then
		Debugger.LogEvent(`[{RunContext}] Create {if reliable then "Reliable" else "Unreliable"} {type} {name}`)
		Runtime.Objects.Network[type][name] = self
	end

	return Runtime.Objects.Network[type][name]
end