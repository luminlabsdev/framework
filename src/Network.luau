--!strict

-- // Package

local NetworkControllerClient = { }
local NetworkControllerServer = { }

local Packages = script.Parent.Parent

-- // Variables

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Indexes = {
	{__index = NetworkControllerClient},
	{__index = NetworkControllerServer},
}

local Future = require(Packages.future)
local Ratelimit = require(Packages.ratelimit)
local Red = require(Packages.red)

local RedServerEvent = Red.Server
local RedClientEvent = Red.Client

-- // Types

export type Server<T...> = {
	Listen: (self: Server<T...>, func: (sender: Player, ...unknown) -> ()) -> (),
	BindToInvocation: (self: Server<T...>, callback: (sender: Player, ...unknown) -> (...any)) -> (),

	Fire: (self: Server<T...>, recipient: Player | {Player}, T...) -> (),
	FireAll: (self: Server<T...>, T...) -> (),
	FireExcept: (self: Server<T...>, except: Player | {Player}, T...) -> (),
	FireInRange: (self: Server<T...>, comparePoint: Vector3, maximumRange: number, T...) -> (),
	FireFilter: (self: Server<T...>, filter: (Player) -> (boolean), T...) -> (),

	SetRateLimit: (self: Server<T...>, maxCalls: number, interval: number?, invokeOverflowCallback: (sender: Player) -> ()?) -> (),

	IsListening: boolean,
	IsBinded: boolean?,
}

export type Client<T...> = {
	Listen: (self: Client<T...>, func: (T...) -> ()) -> (),

	Fire: (self: Client<T...>, T...) -> (),
	InvokeAsync: (self: Client<T...>, T...) -> (Future.Future<...any>),

	IsListening: boolean,
	IsBinded: boolean?,
}

-- // Functions

local function PackArgs(...: any)
	return {...}
end

-- // Network Controller Client

function NetworkControllerClient:Fire(...: any)
	RedClientEvent.Fire(self._Names._Event, PackArgs(...))
end

function NetworkControllerClient:Listen(func: (...any) -> ())
	assert(not self.IsListening, "Controller is already subscribed to an event")
	assert(func, "Must provide a listener")

	self.IsListening = true

	RedClientEvent.Listen(self._Names._Event, func)
end

function NetworkControllerClient:InvokeAsync(...: any): Future.Future<...any>
	return RedClientEvent.Call(self._Names._Function, PackArgs(...))
end

-- // Network Controller Server

function NetworkControllerServer:Fire(recipients: Player | {Player}, ...: any)
	if type(recipients) == "table" then
		for _, player in recipients do
			RedServerEvent.Fire(player, self._Names._Event, PackArgs(...))
		end

		return
	end

	RedServerEvent.Fire(recipients, self._Names._Event, PackArgs(...))
end

function NetworkControllerServer:FireAll(...: any)
	for _, player in PlayerService:GetPlayers() do
		RedServerEvent.Fire(player, self._Names._Event, PackArgs(...))
	end
end

function NetworkControllerServer:FireExcept(except: Player | {Player}, ...: any)
	if type(except) == "table" then
		for _, player in PlayerService:GetPlayers() do
			if table.find(except, player) then
				continue
			end

			RedServerEvent.Fire(player, self._Names._Event, PackArgs(...))
		end

		return
	end

	for _, player in PlayerService:GetPlayers() do
		if player == except then
			continue
		end

		RedServerEvent.Fire(player, self._Names._Event, PackArgs(...))
	end
end

function NetworkControllerServer:FireFilter(filter: (Player) -> (boolean), ...: any)
	for _, player in PlayerService:GetPlayers() do
		if filter(player) then
			RedServerEvent.Fire(player, self._Names._Event, PackArgs(...))
		end
	end
end

function NetworkControllerServer:FireInRange(comparePoint: Vector3, maximumRange: number, ...: any)
	self:FireFilter(function(player) -- reuse FireFilter to follow D.R.Y. standards
		if player:DistanceFromCharacter(comparePoint) <= maximumRange then
			return true
		end
		return false
	end, ...)
end

function NetworkControllerServer:Listen(func: (sender: Player, ...unknown) -> ())
	assert(not self.IsListening, "Controller is already subscribed to an event")
	assert(func, "Must provide a listener")
	
	self.IsListening = true

	RedServerEvent.Listen(self._Names._Event, function(player, ...)
		if (self._Ratelimit and self._InvokeOverflow) and not self._Ratelimit(player) then
			self._InvokeOverflow(player)
			return
		end

		func(player, ...)
	end)
end

function NetworkControllerServer:SetRateLimit(maxCalls: number, interval: number?, invokeOverflowCallback: (sender: Player) -> ()?)
	if maxCalls <= -1 then
		self._Ratelimit = nil
		self._InvokeOverflow = nil
	end

	if not (interval and invokeOverflowCallback) then
		return
	end

	self._Ratelimit = Ratelimit(maxCalls, interval or 1)
	self._InvokeOverflow = invokeOverflowCallback :: any
end

function NetworkControllerServer:BindToInvocation(callback: (sender: Player, ...unknown) -> (...any))
	assert(not self.IsBinded, "Controller already has function binded to invocation")
	self.IsBinded = true

	RedServerEvent.Listen(self._Names._Function, function(player, ...)
		return callback(player, ...)
	end)
end

-- // Actions

table.freeze(NetworkControllerServer)
table.freeze(NetworkControllerClient)

return function(name: string): Server<...any> & Client<...any>
	return setmetatable({
		IsListening = false,
		IsBinded = nil,

		_Ratelimit = nil,
		_InvokeOverflow = nil,

		_Names = table.freeze({ -- Lock its own table to make sure there's no issues
			_Event = `{name}_E`, -- Use small names to preserve memory
			_Function = `{name}_F`,
		})
	}, if RunService:IsClient() then Indexes[1] else Indexes[2]) :: any
end