-- // NetworkController
--[=[
	The parent of all classes.

	@class NetworkController
]=]
local NetworkController = { }

--[=[
	The NetworkControllerServer class.

	@client
	@class NetworkControllerClient
]=]
local NetworkControllerClient = { }

--[=[
	The name of the the network controller.

	@readonly

	@prop Name string
	@within NetworkControllerClient
]=]

--[=[
	The bridge for use in BridgeNet.

	@readonly
	@private

	@prop _Bridge ClientBridge
	@within NetworkControllerClient
]=]

--[=[
	The NetworkControllerServer class.

	@server
	@class NetworkControllerServer
]=]
local NetworkControllerServer = { }

--[=[
	The name of the the network controller.

	@readonly

	@prop Name string
	@within NetworkControllerServer
]=]

--[=[
	The bridge for use in BridgeNet.

	@readonly
	@private

	@prop _Bridge ServerBridge
	@within NetworkControllerServer
]=]

local Indexes = {
	{__index = NetworkControllerClient},
	{__index = NetworkControllerServer},
}

local Vendor = script.Vendor

-- // Variables

local BridgeNet = require(Vendor.BridgeNet2)

-- // Functions

--[=[
	Sanitizes data sent through `:Fire`.

	@private

	@param data any -- The data to sanitize
	@return {any}
]=]
function NetworkController.SanitizeData(data: any)
	if type(data) ~= "table" then
		return {data}
	end
	
	return data
end

-- // Constructors

--[=[
	Creates a new client network controller.

	@ignore

	@param name string -- The name of the new controller
	@return NetworkControllerClient
]=]
function NetworkController.NewClientController(name: string)
	local self = setmetatable({ }, Indexes[1])
	
	self._Bridge = BridgeNet.ReferenceBridge(name)
	self.Name = name
	
	return self
end

--[=[
	Creates a new server network controller.

	@ignore

	@param name string -- The name of the new controller
	@return NetworkControllerServer
]=]
function NetworkController.NewServerController(name: string)
	local self = setmetatable({ }, Indexes[2])

	self._Bridge = BridgeNet.ReferenceBridge(name)
	self.Name = name

	return self
end

--[=[
	Fires an event which sends data to the server, equivalent to [RemoteEvent:FireServer]

	:::tip

	If you're firing a single piece of data, there is no need to wrap it in a table!

	```lua
	NetworkController:Fire("Hello, world!")
	```

	:::

	@param data ({any} | any)? -- The data that should be sent to the server
]=]
function NetworkControllerClient:Fire(data: ({any} | any)?)
	self._Bridge:Fire(NetworkController.SanitizeData(data))
end

--[=[
	Connects a function to the event that is fired when the server fires the network controller. When using `:Once`, the function is only run the first time and then the connection is disconnected automatically.

	@param func (data: {any}) -> () -- The function to call when data is recieved from the server
	@return ScriptConnection
]=]
function NetworkControllerClient:Once(func: (data: {any}?) -> ())
	return self._Bridge:Once(func)
end

--[=[
	Connects a function to the event that is fired when the server fires the network controller.

	@param func (data: {any}) -> () -- The function to call when data is recieved from the server
	@return ScriptConnection
]=]
function NetworkControllerClient:Connect(func: (data: {any}?) -> ())
	return self._Bridge:Connect(func)
end

--[=[
	Yields the current thread until the server fires the network controller.

	@yields
	@return {any}
]=]
function NetworkControllerClient:Wait(): {any}?
	return self._Bridge:Wait()
end

--[=[
	Invokes the server, equivalent to [RemoteFunction:InvokeServer].

	@yields

	@param data ({any} | any)? -- The data to invoke the server with
	@return {any}
]=]
function NetworkControllerClient:InvokeAsync(data: ({any} | any)?)	
	return NetworkController.SanitizeData(self._Bridge:InvokeServerAsync(NetworkController.SanitizeData(data)))
end

-- // Network Controller Server

--[=[
	Fires an event which sends data to the client, equivalent to [RemoteEvent:FireClient].

	:::tip

	If you need to fire the event to multiple players instead of one, you can use a table of players.

	```lua
	NetworkController:Fire({Player1, Player2, Player3}, {1, 2, 3})
	```

	:::

	@param recipients Player | {Player} -- The players who should recieve the data and/or call
	@param data ({any} | any)? -- The data that should be sent to the client
]=]
function NetworkControllerServer:Fire(recipients: Player | {Player}, data: ({any} | any)?)
	if type(recipients) ~= "table" then
		self._Bridge:Fire(recipients, NetworkController.SanitizeData(data))
		return
	end
	
	self._Bridge:Fire(BridgeNet.Players(recipients), NetworkController.SanitizeData(data))
end

--[=[
	Fires an event which sends data to every client connected to the server, equivalent to [RemoteEvent:FireAllClients].

	@param data ({any} | any)? -- The data that should be sent to each player
]=]
function NetworkControllerServer:FireAll(data: ({any} | any)?)
	self._Bridge:Fire(BridgeNet.AllPlayers(), NetworkController.SanitizeData(data))
end

--[=[
	Fires an event which sends data to every client connected to the server, except for players in the `except` parameter.

	@param except Player | {Player} -- The players which the call should not be sent to
	@param data ({any} | any)? -- The data that should be sent to each player except `except`
]=]
function NetworkControllerServer:FireExcept(except: Player | {Player}, data: ({any} | any)?)
	if type(except) ~= "table" then
		self._Bridge:Fire(BridgeNet.PlayersExcept({except}), NetworkController.SanitizeData(data))
		return
	end

	self._Bridge:Fire(BridgeNet.PlayersExcept(except), NetworkController.SanitizeData(data))
end

--[=[
	Recieves an invoke from the server, and runs the callback function which returns some data. Equivalent to [RemoteFunction.OnServerInvoke].

	@param callback (sender: Player, data: {any}) -> (({any} | any)?) -- The callback function to run on invoke, must return at least 1 value.
]=]
function NetworkControllerServer:OnInvoke(callback: (sender: Player, data: {any}) -> (({any} | any)))
	self._Bridge.OnServerInvoke = callback
end

--[=[
	Connects a function to the event that is fired when the client fires the network controller. When using `:Once`, the function is only run the first time and then the connection is disconnected automatically.

	@param func (sender: Player, data: {any}) -> () -- The function to call when data is recieved from the client
	@return ScriptConnection
]=]
function NetworkControllerServer:Once(func: (sender: Player, data: {any}?) -> ())
	return self._Bridge:Once(func)
end

--[=[
	Connects a function to the event that is fired when the server fires the network controller.

	@param func (sender: Player, data: {any}) -> () -- The function to call when data is recieved from the server
	@return ScriptConnection
]=]
function NetworkControllerServer:Connect(func: (sender: Player, data: {any}?) -> ())
	return self._Bridge:Connect(func)
end

--[=[
	Yields the current thread until the client fires the network controller.

	@yields
	@return {any}
]=]
function NetworkControllerServer:Wait(): (Player, {any})
	return self._Bridge:Wait()
end

-- // Actions

return NetworkController