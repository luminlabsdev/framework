-- // Package

local Client = { }
local Server = { }

-- // Variables

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Indexes = {
	{__index = Client},
	{__index = Server},
}

local Future = require(script.Parent.Parent.future)
local Ratelimit = require(script.Parent.Parent.ratelimit)
local Spawn = require(script.Parent.Parent.spawn)
local Red = require(script.Parent.Parent.red)

local RedIdentifier = Red.Identifier

local RedServerEvent = Red.Server
local RedClientEvent = Red.Client

-- // Types

export type Server<T...> = {
	Listen: (self: Server<T...>, func: (sender: Player, ...unknown) -> ()) -> (),
	BindToInvocation: (self: Server<T...>, callback: (sender: Player, ...unknown) -> (any, ...any)) -> (),

	Fire: (self: Server<T...>, recipient: Player | {Player}, T...) -> (),
	FireAll: (self: Server<T...>, T...) -> (),
	FireExcept: (self: Server<T...>, except: Player | {Player}, T...) -> (),
	FireInRange: (self: Server<T...>, comparePoint: Vector3, maximumRange: number, T...) -> (),
	FireFilter: (self: Server<T...>, filter: (Player) -> (boolean), T...) -> (),

	SetRateLimit: (self: Server<T...>, maxCalls: number, resetInterval: number?, invokeOverflowCallback: (sender: Player) -> ()?) -> (),

	IsListening: boolean,
	IsFunctionBound: boolean?,
	IsReliable: boolean,
}

export type Client<T...> = {
	Listen: (self: Client<T...>, func: (T...) -> ()) -> (),

	Fire: (self: Client<T...>, T...) -> (),
	InvokeAsync: (self: Client<T...>, T...) -> (Future.Future<...any>),

	IsListening: boolean,
	IsReliable: boolean,
}

-- // Functions

-- // Client

function Client:Fire(...: any)
	if self.IsReliable then
		RedClientEvent.SendReliableEvent(self._Names._Event, table.pack(...))
	else
		RedClientEvent.SendUnreliableEvent(self._Names._Event, table.pack(...))
	end
end

function Client:Listen(func: (...any) -> ())
	assert(func, "Must provide a listener")

	self.IsListening = true

	RedClientEvent.SetListener(self._Names._Event, function(args)
		func(table.unpack(args))
	end)
end

function Client:InvokeAsync(...: any): Future.Future<...any>
	return Future.new(function(...: any)
		return table.unpack(RedClientEvent.CallAsync(self._Names._Function, table.pack(RedIdentifier.Unique(), ...)))
	end, ...)
end

-- // Server

function Server:Fire(recipients: Player | {Player}, ...: any)
	if type(recipients) == "table" then
		if self.IsReliable then
			for _, player in recipients do
				RedServerEvent.SendReliableEvent(player, self._Names._Event, table.pack(...))
			end
		else
			for _, player in recipients do
				RedServerEvent.SendUnreliableEvent(player, self._Names._Event, table.pack(...))
			end
		end
		return
	end

	if self.IsReliable then
		RedServerEvent.SendReliableEvent(recipients, self._Names._Event, table.pack(...))
	else
		RedServerEvent.SendUnreliableEvent(recipients, self._Names._Event, table.pack(...))
	end
end

function Server:FireAll(...: any)
	if self.IsReliable then
		for _, player in PlayerService:GetPlayers() do
			RedServerEvent.SendReliableEvent(player, self._Names._Event, table.pack(...))
		end
	else
		for _, player in PlayerService:GetPlayers() do
			RedServerEvent.SendUnreliableEvent(player, self._Names._Event, table.pack(...))
		end
	end
end

function Server:FireExcept(except: Player | {Player}, ...: any)
	if type(except) == "table" then
		for _, player in PlayerService:GetPlayers() do
			if table.find(except, player) then
				continue
			end

			if self.IsReliable then
				RedServerEvent.SendReliableEvent(player, self._Names._Event, table.pack(...))
			else
				RedServerEvent.SendUnreliableEvent(player, self._Names._Event, table.pack(...))
			end
		end

		return
	end

	for _, player in PlayerService:GetPlayers() do
		if player == except then
			continue
		end

		if self.IsReliable then
			RedServerEvent.SendReliableEvent(player, self._Names._Event, table.pack(...))
		else
			RedServerEvent.SendUnreliableEvent(player, self._Names._Event, table.pack(...))
		end
	end
end

function Server:FireFilter(filter: (Player) -> (boolean), ...: any)
	for _, player in PlayerService:GetPlayers() do
		if filter(player) then
			if self.IsReliable then
				RedServerEvent.SendReliableEvent(player, self._Names._Event, table.pack(...))
			else
				RedServerEvent.SendUnreliableEvent(player, self._Names._Event, table.pack(...))
			end
		end
	end
end

function Server:FireInRange(comparePoint: Vector3, maximumRange: number, ...: any)
	self:FireFilter(function(player) -- reuse FireFilter to follow D.R.Y. standards
		if player:DistanceFromCharacter(comparePoint) <= maximumRange then
			return true
		end
		return false
	end, ...)
end

function Server:Listen(func: (sender: Player, ...unknown) -> ())
	assert(func, "Must provide a listener")
	
	self.IsListening = true

	RedServerEvent.SetListener(self._Names._Event, function(player, args)
		if (self._Ratelimit and self._InvokeOverflow) and not self._Ratelimit(player) then
			self._InvokeOverflow(player)
			return
		end

		func(player, table.unpack(args))
	end)
end

function Server:SetRateLimit(maxCalls: number, resetInterval: number?, invokeOverflowCallback: (sender: Player) -> ()?)
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

function Server:BindToInvocation(callback: (sender: Player, ...unknown) -> (unknown, ...any))
	self.IsFunctionBound = true

	RedServerEvent.SetListener(self._Names._Function, function(player, args)
		if (self._Ratelimit and self._InvokeOverflow) and not self._Ratelimit(player) then
			self._InvokeOverflow(player)
			return
		end

		local callId = table.remove(args, 1)

		if type(callId) ~= "string" then
			return
		end

		Spawn(function(player: Player, callId: string, ...: any)
			RedServerEvent.SendCallReturn(player, callId, table.pack(callback(player, ...)))
		end, player, callId, table.unpack(args))
	end)
end

-- // Actions

table.freeze(Server)
table.freeze(Client)

return function(name: string, isUnreliable: boolean?): Server<...any> & Client<...any>
	assert(not RedIdentifier.Exists(`{name}_E`) or not RedIdentifier.Exists(`{name}_F`), "Cannot use same controller name multiple times")
	return setmetatable({
		IsListening = false,
		IsFunctionBound = nil,

		IsReliable = if isUnreliable ~= nil then not isUnreliable else true,

		_Ratelimit = nil,
		_InvokeOverflow = nil,

		_Names = table.freeze({ -- Lock its own table to make sure there's no conflicts
			_Event = RedIdentifier.Shared(`{name}_E`):Await(),
			_Function = RedIdentifier.Shared(`{name}_F`):Await(),
		})
	}, if RunService:IsClient() then Indexes[1] else Indexes[2]) :: any
end