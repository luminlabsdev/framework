-- // Package

local NetworkControllerClient = { }
local NetworkControllerServer = { }

local Vendor = script.Parent.Vendor

-- // Variables

local EngineVendor = Vendor.Parent.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Indexes = {
	{__index = NetworkControllerClient},
	{__index = NetworkControllerServer},
}

local Future = require(EngineVendor.Libraries.RedbloxUtils.Future)
local Ratelimit = require(EngineVendor.Libraries.RedbloxUtils.Ratelimit)
local Types = require(EngineVendor.Types)

local MainRedRemote: RemoteEvent
local ClientFolder: ScreenGui

if RunService:IsServer() then
	if ReplicatedStorage:FindFirstChild("RedEvent") then
		MainRedRemote = ReplicatedStorage:FindFirstChild("RedEvent")
	else
		MainRedRemote = Instance.new("RemoteEvent")
		MainRedRemote.Name = "RedEvent"
		MainRedRemote.Parent = ReplicatedStorage
	end

	require(Vendor.Red.ServerEvent).Start()

	local function PlayerAdded(player: Player)
		local ClientFolderCreate = Instance.new("ScreenGui")

		ClientFolderCreate.Enabled = false
		ClientFolderCreate.ResetOnSpawn = false
		ClientFolderCreate.Name = "Red"
		ClientFolderCreate.Parent = player:WaitForChild("PlayerGui")
	end

	PlayerService.PlayerAdded:Connect(PlayerAdded)

	for _, player in PlayerService:GetPlayers() do
		PlayerAdded(player)
	end
else
	local Player = PlayerService.LocalPlayer
	MainRedRemote = ReplicatedStorage:FindFirstChild("RedEvent")

	require(Vendor.Red.ClientEvent).Start()

	ClientFolder = Player:WaitForChild("PlayerGui"):WaitForChild("Red")
	ClientFolder.Parent = nil
end

local RedServerEvent = require(Vendor.Red.ServerEvent)
local RedClientEvent = require(Vendor.Red.ClientEvent)

-- // Types

export type Server<T...> = {
	Listen: (self: Server<T...>, func: (sender: Player, ...unknown) -> ()) -> (),
	BindToInvocation: (self: Server<T...>, callback: (sender: Player, ...unknown) -> (...any)) -> (),

	Fire: (self: Server<T...>, recipient: Player | Types.Array<Player>, T...) -> (),
	FireAll: (self: Server<T...>, T...) -> (),
	FireExcept: (self: Server<T...>, except: Player | Types.Array<Player>, T...) -> (),
	FireInRange: (self: Server<T...>, comparePoint: Vector3, maximumRange: number, T...) -> (),
	FireFilter: (self: Server<T...>, filter: (Player) -> (boolean), T...) -> (),

	SetRateLimit: (self: Server<T...>, maxInvokesPerSecond: number, invokeOverflowCallback: (sender: Player) -> ()) -> (),
}

export type Client<T...> = {
	Listen: (self: Client<T...>, func: (T...) -> ()) -> (),

	Fire: (self: Client<T...>, T...) -> (),
	InvokeAsync: (self: Client<T...>, T...) -> (Future.Future<...any>),
}

-- // Functions

local function PackArgs(...: any)
	return {...}
end

-- Network Controller Client

function NetworkControllerClient:Fire(...: any)
	RedClientEvent.Fire(self._EventName, PackArgs(...))
end

function NetworkControllerClient:Listen(func: (...any) -> ())
	assert(not self.IsListening, "Controller is already subscribed to an event")
	self.IsListening = true

	RedClientEvent.Listen(self._EventName, func)
end

function NetworkControllerClient:InvokeAsync(...: any): Future.Future<...any>
	return RedClientEvent.Call(self._FunctionName, PackArgs(...))
end

-- Network Controller Server

function NetworkControllerServer:Fire(recipients: Player | {Player}, ...: any)
	if type(recipients) == "table" then
		for _, player in recipients do
			RedServerEvent.Fire(player, self._EventName, PackArgs(...))
		end

		return
	end

	RedServerEvent.Fire(recipients, self._EventName, PackArgs(...))
end

function NetworkControllerServer:FireAll(...: any)
	for _, player in PlayerService:GetPlayers() do
		RedServerEvent.Fire(player, self._EventName, PackArgs(...))
	end
end

function NetworkControllerServer:FireExcept(except: Player | {Player}, ...: any)
	if type(except) == "table" then
		for _, player in PlayerService:GetPlayers() do
			if table.find(except, player) then
				continue
			end

			RedServerEvent.Fire(player, self._EventName, PackArgs(...))
		end

		return
	end

	for _, player in PlayerService:GetPlayers() do
		if player == except then
			continue
		end

		RedServerEvent.Fire(player, self._EventName, PackArgs(...))
	end
end

function NetworkControllerServer:FireFilter(filter: (Player) -> (boolean), ...: any)
	for _, player in PlayerService:GetPlayers() do
		if filter(player) then
			RedServerEvent.Fire(player, self._EventName, PackArgs(...))
		end
	end
end

function NetworkControllerServer:FireInRange(comparePoint: Vector3, maximumRange: number, ...: any)
	self:FireFilter(function(player) -- reuse FireFilter to follow D.R.Y. standards
		if player:DistanceFromCharacter(comparePoint) <= maximumRange then
			return true
		end
	end, PackArgs(...))
end

function NetworkControllerServer:Listen(func: (sender: Player, ...unknown) -> ())
	assert(not self.IsListening, "Controller is already subscribed to an event")
	self.IsListening = true

	RedServerEvent.Listen(self._EventName, function(player, ...)
		if (self._Ratelimit and self._InvokeOverflow) and not self._Ratelimit(player) then
			self._InvokeOverflow(player)
			return
		end

		func(player, ...)
	end)
end

function NetworkControllerServer:SetRateLimit(maxCalls: number, interval: number?, invokeOverflowCallback: ((sender: Player) -> ())?)
	if maxCalls <= -1 then
		self._Ratelimit = nil
		self._InvokeOverflow = nil
	end

	if not (interval or invokeOverflowCallback) then
		return
	end

	self._Ratelimit = Ratelimit(maxCalls, interval or 1)
	self._InvokeOverflow = invokeOverflowCallback or function(player: Player)
		warn(player.UserId, "exceeded call limit")
	end
end

function NetworkControllerServer:BindToInvocation(callback: (sender: Player, ...unknown) -> (...any))
	assert(not self.IsBinded, "Controller already has function binded to invocation")
	self.IsBinded = true

	RedServerEvent.Listen(self._FunctionName, function(player, ...)
		return callback(player, ...)
	end)
end

-- // Actions

table.freeze(NetworkControllerServer)
table.freeze(NetworkControllerClient)

return function(name: string)
	return setmetatable({
		IsListening = false,
		IsBinded = nil,

		_Ratelimit = nil,
		_InvokeOverflow = nil,

		_EventName = `{name}_E`, -- Use small names to preserve memory
		_FunctionName = `{name}_F`,
	}, if RunService:IsClient() then Indexes[1] else Indexes[2])
end