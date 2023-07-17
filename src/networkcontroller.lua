-- // Package

local Package = { }

local Client = { }
local Server = { }

local Indexes = {
	{__index = Client};
	{__index = Server};
}

local Vendor = script:WaitForChild("Vendor")

-- // Variables

local BridgeNet = require(Vendor.BridgeNet2)

-- // Functions

local function SanitizeData(data: any)
	if type(data) ~= "table" then
		return {data}
	end
	
	return data
end

-- // Constructors

function Package.NewClientController(name: string)
	local self = setmetatable({ }, Indexes[1])
	
	self._networkMain = BridgeNet.ReferenceBridge(`{name}_Signal`)
	self.Name = name
	
	return self
end

function Package.NewServerController(name: string)
	local self = setmetatable({ }, Indexes[2])

	self._networkMain = BridgeNet.ReferenceBridge(`{name}_Signal`)
	self.Name = name

	return self
end

-- // Network Controller Client

function Client:Fire(data: ({any} | any)?)
	local NetworkMain = self._networkMain
	
	NetworkMain:Fire(SanitizeData(data))
end

function Client:Once(func: (data: {any}?) -> ())
	return self._networkMain:Once(func)
end

function Client:Connect(func: (data: {any}?) -> ())
	return self._networkMain:Connect(func)
end

function Client:Wait(): {any}?
	return self._networkMain:Wait()
end

function Client:InvokeAsync(data: ({any} | any)?)
	local NetworkMain = self._networkMain
	
	return SanitizeData(NetworkMain:InvokeServerAsync(SanitizeData(data)))
end

-- // Network Controller Server

function Server:Fire(recipients: Player | {Player}, data: ({any} | any)?)
	local NetworkMain = self._networkMain

	if type(recipients) ~= "table" then
		NetworkMain:Fire(recipients, SanitizeData(data))
		return
	end
	
	NetworkMain:Fire(BridgeNet.Players(recipients), SanitizeData(data))
end

function Server:FireAll(data: ({any} | any)?)
	local NetworkMain = self._networkMain
	
	NetworkMain:Fire(BridgeNet.AllPlayers(), SanitizeData(data))
end

function Server:OnInvoke(callback: (sender: Player, data: {any}) -> (({any} | any)?))
	local NetworkMain = self._networkMain
	
	NetworkMain.OnServerInvoke = callback
end

function Server:Once(func: (sender: Player, data: {any}?) -> ())
	return self._networkMain:Once(func)
end

function Server:Connect(func: (sender: Player, data: {any}?) -> ())
	return self._networkMain:Connect(func)
end

function Server:Wait(): (Player, {any})
	return self._networkMain:Wait()
end

-- // Actions

return Package