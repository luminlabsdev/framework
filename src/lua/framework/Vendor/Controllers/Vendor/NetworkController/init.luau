-- // Package

local NetworkController = { }
local NetworkControllerClient = { }
local NetworkControllerServer = { }

local Vendor = script.Parent.Vendor

-- // Variables

local EngineVendor = Vendor.Parent.Parent.Parent.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Indexes = {
	{__index = NetworkControllerClient},
	{__index = NetworkControllerServer},
}

local Future = require(EngineVendor.Libraries.RedbloxUtils.Future)
local Ratelimit = require(Vendor.Ratelimit)
local Sanitize = require(Vendor.Parent.Parent.Sanitize)

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

-- // Functions

local function ValidateTuple(...: any)
	if select("#", ...) > 1 then
		warn("Invalid data")
		return false
	end
	return true
end

-- // Constructors

function NetworkController.CreateController(name: string)
	local self = setmetatable({ }, if RunService:IsClient() then Indexes[1] else Indexes[2])

	self.Name = name
	self.IsListening = false
	self.IsBinded = nil
	
	self._Ratelimit = nil
	self._InvokeOverflow = nil

	self._EventName = `{name}_E`
	self._FunctionName = `{name}_F`

	return self
end

-- Network Controller Client

function NetworkControllerClient:Fire(data: ({any} | any)?)
	RedClientEvent.Fire(self._EventName, Sanitize(data))
end

function NetworkControllerClient:Listen(func: (data: {any}?) -> ())
	assert(not self.IsListening, "Controller is already subscribed to an event")
	self.IsListening = true

	RedClientEvent.Listen(self._EventName, function(...)
		local ValidData = ValidateTuple(...)

		if not ValidData then
			return
		end

		local SanitizedData = Sanitize(...)

		if #SanitizedData == 0 then
			func(nil)
			return
		end

		func(SanitizedData)
	end)
end

function NetworkControllerClient:InvokeAsync(data: ({any} | any)?): Future.Future<any>
	return RedClientEvent.Call(self._FunctionName, Sanitize(data))
end

-- Network Controller Server

function NetworkControllerServer:Fire(recipients: Player | {Player}, data: ({any} | any)?)
	if type(recipients) == "table" then
		for _, player in recipients do
			RedServerEvent.Fire(player, self._EventName, Sanitize(data))
		end

		return
	end
	
	RedServerEvent.Fire(recipients, self._EventName, Sanitize(data))
end

function NetworkControllerServer:FireAll(data: ({any} | any)?)
	for _, player in PlayerService:GetPlayers() do
		RedServerEvent.Fire(player, self._EventName, Sanitize(data))
	end
end

function NetworkControllerServer:FireExcept(except: Player | {Player}, data: ({any} | any)?)
	if type(except) ~= "table" then -- don't use typeof(), for optimization
		except = {except}
	end

	for _, player in PlayerService:GetPlayers() do
		if table.find(except, player) then
			continue
		end

		RedServerEvent.Fire(player, self._EventName, Sanitize(data))
	end
end

function NetworkControllerServer:FireFilter(data: ({any} | any)?, filter: (Player) -> (boolean))
	for _, player in PlayerService:GetPlayers() do
		if filter(player) then
			RedServerEvent.Fire(player, self._EventName, Sanitize(data))
		end
	end
end

function NetworkControllerServer:FireInRange(comparePoint: Vector3, maximumRange: number, data: ({any} | any)?)
	self:FireFilter(data, function(player) -- reuse FireFilter to follow D.R.Y. standards
		if player:DistanceFromCharacter(comparePoint) <= maximumRange then
			return true
		end
	end)
end

function NetworkControllerServer:Listen(func: (sender: Player, data: {any}?) -> ())
	assert(not self.IsListening, "Controller is already subscribed to an event")
	self.IsListening = true
	
	RedServerEvent.Listen(self._EventName, function(player, ...)
		if (self._Ratelimit and self._InvokeOverflow) and not self._Ratelimit(player) then
			self._InvokeOverflow(player)
			return
		end

		local ValidData = ValidateTuple(...)

		if not ValidData then
			return
		end

		local SanitizedData = Sanitize(...)

		if #SanitizedData == 0 then
			func(player, nil)
			return
		end

		func(player, SanitizedData)
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

	self._Ratelimit = Ratelimit(maxCalls, interval)
	self._InvokeOverflow = invokeOverflowCallback
end

function NetworkControllerServer:BindToInvocation(callback: (sender: Player, data: {any}?) -> (({any} | any)))
	assert(not self.IsBinded, "Controller already has function binded to invocation")
	self.IsBinded = true

	RedServerEvent.Listen(self._FunctionName, function(player, data)
		return Sanitize(callback(player, Sanitize(data)))
	end)
end

-- // Actions

table.freeze(NetworkControllerServer)
table.freeze(NetworkControllerClient)

return table.freeze(NetworkController)