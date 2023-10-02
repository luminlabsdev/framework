-- // Package

local NetworkController = { }
local NetworkControllerClient = { }
local NetworkControllerServer = { }

local Vendor = script.Parent.Vendor

-- // Variables

local EngineVendor = Vendor.Parent.Parent.Parent.Parent

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Indexes = {
	{__index = NetworkControllerClient},
	{__index = NetworkControllerServer},
}

local Future = require(EngineVendor.Libraries.RedbloxUtils.Future)
local BridgeNet = require(Vendor.BridgeNet2.BridgeNet2)
local Sanitize = require(Vendor.Parent.Parent.Sanitize)

-- // Functions

-- // Constructors

function NetworkController.CreateController(name: string)
	local self = setmetatable({ }, RunService:IsClient() and Indexes[1] or Indexes[2])

	self.Name = name
	self._Event = BridgeNet.ReferenceBridge(name)

	return self
end

-- Network Controller Client

function NetworkControllerClient:Fire(data: ({any} | any)?)
	self._Event:Fire(Sanitize(data))
end

function NetworkControllerClient:Listen(func: (data: {any}?) -> ())
	self._Event:Connect(func)
end

function NetworkControllerClient:InvokeAsync(data: ({any} | any)?)
	return Future.new(function()
		return Sanitize(self._Event:InvokeServerAsync(Sanitize(data)))
	end)
end

-- Network Controller Server

function NetworkControllerServer:Fire(recipients: Player | {Player}, data: ({any} | any)?)
	if type(recipients) ~= "table" then
		self._Event:Fire(recipients, Sanitize(data))
		return
	end
	
	self._Event:Fire(BridgeNet.Players(recipients), Sanitize(data))
end

function NetworkControllerServer:FireAll(data: ({any} | any)?)
	self._Event:Fire(BridgeNet.AllPlayers(), Sanitize(data))
end

function NetworkControllerServer:FireExcept(except: Player | {Player}, data: ({any} | any)?)
	if type(except) ~= "table" then
		self._Event:Fire(BridgeNet.PlayersExcept({except}), Sanitize(data))
		return
	end

	self._Event:Fire(BridgeNet.PlayersExcept(except), Sanitize(data))
end

function NetworkControllerServer:FireInRange(comparePoint: Vector3, maximumRange: number, data: ({any} | any)?)
	local PlayersToFireTo = { }

	for _, player: Player in PlayerService:GetPlayers() do
		if player:DistanceFromCharacter(comparePoint) <= maximumRange then
			table.insert(PlayersToFireTo, player)
		end
	end

	self:Fire(PlayersToFireTo, data)
end

function NetworkControllerServer:Listen(func: (sender: Player, data: {any}?) -> ())
	self._Event:Connect(func)
end

function NetworkControllerServer:SetRateLimit(maxInvokesPerSecond: number, invokeOverflowCallback: ((sender: Player) -> ())?)
	if maxInvokesPerSecond <= -1 then
		self._Bridge:DisableRateLimit()
		return
	end

	if not invokeOverflowCallback then
		return
	end

	self._Event:RateLimit(maxInvokesPerSecond, invokeOverflowCallback)
end

function NetworkControllerServer:BindToInvocation(callback: (sender: Player, data: {any}?) -> (({any} | any)))
	self._Event.OnServerInvoke = callback
end

-- // Actions

table.freeze(NetworkControllerServer)
table.freeze(NetworkControllerClient)

return table.freeze(NetworkController)