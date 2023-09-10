-- // NetworkController
--[=[
	The parent of all classes.

	@ignore
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
	A list of connections.

	@private

	@prop _Connections {ControllerConnection}
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
	A list of connections.

	@private

	@prop _Connections {ControllerConnection}
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

-- // Variables

local Vendor = script.Parent.Vendor
local PlayerService = game:GetService("Players")

local BridgeNet = require(Vendor.BridgeNet2)
local SanitizeData = require(Vendor.Parent.Parent.SanitizeData)

-- // Functions

-- // Constructors

--[=[
	Creates a new client network controller.

	@param name string -- The name of the new controller
	@return NetworkControllerClient
]=]
function NetworkController.NewClientController(name: string, timeout: number)
	local self = setmetatable({ }, Indexes[1])
	
	self._Bridge = BridgeNet.ClientBridge(name, timeout)
	self._Connections = { }
	self.Name = name
	
	return self
end

--[=[
	Creates a new server network controller.

	@param name string -- The name of the new controller
	@return NetworkControllerServer
]=]
function NetworkController.NewServerController(name: string)
	local self = setmetatable({ }, Indexes[2])

	self._Bridge = BridgeNet.ServerBridge(name)
	self._Connections = { }
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
	self._Bridge:Fire(SanitizeData.SanitizeData(data))
end

--[=[
	Connects a function to the event that is fired when the server fires the network controller. When using `:Once`, the function is only run the first time and then the connection is disconnected automatically.

	@param func (data: {any}) -> () -- The function to call when data is recieved from the server
	@return ControllerConnection
]=]
function NetworkControllerClient:Once(func: (data: {any}?) -> ())
	local Connection = self._Bridge:Connect(func)

	table.insert(self._Connections, Connection)
	return Connection
end

--[=[
	Connects a function to the event that is fired when the server fires the network controller.

	@param func (data: {any}) -> () -- The function to call when data is recieved from the server
	@return ControllerConnection
]=]
function NetworkControllerClient:Connect(func: (data: {any}?) -> ())
	local Connection = self._Bridge:Connect(func)

	table.insert(self._Connections, Connection)
	return Connection
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
	return SanitizeData.SanitizeData(self._Bridge:InvokeServerAsync(SanitizeData.SanitizeData(data)))
end

--[=[
	Disconnects all listeners from the current network controller.
]=]
function NetworkControllerClient:DisconnectAll()
	for _, connection in self._Connections do
		connection:Disconnect()
	end
end

--[=[
	Destroys the current network controller.
]=]
function NetworkControllerClient:Destroy()
	self._Bridge:Destroy()
	table.clear(self)
	setmetatable(self, nil)
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
		self._Bridge:Fire(recipients, SanitizeData.SanitizeData(data))
		return
	end
	
	self._Bridge:Fire(BridgeNet.Players(recipients), SanitizeData.SanitizeData(data))
end

--[=[
	Fires an event which sends data to every client connected to the server, equivalent to [RemoteEvent:FireAllClients].

	@param data ({any} | any)? -- The data that should be sent to each player
]=]
function NetworkControllerServer:FireAll(data: ({any} | any)?)
	self._Bridge:Fire(BridgeNet.AllPlayers(), SanitizeData.SanitizeData(data))
end

--[=[
	Fires an event which sends data to every client connected to the server, except for players in the `except` parameter.

	@param except Player | {Player} -- The players which the call should not be sent to
	@param data ({any} | any)? -- The data that should be sent to each player except `except`
]=]
function NetworkControllerServer:FireExcept(except: Player | {Player}, data: ({any} | any)?)
	if type(except) ~= "table" then
		self._Bridge:Fire(BridgeNet.PlayersExcept({except}), SanitizeData.SanitizeData(data))
		return
	end

	self._Bridge:Fire(BridgeNet.PlayersExcept(except), SanitizeData.SanitizeData(data))
end

--[=[
	Fires an event which sends data to every client that is within `maximumRange` studs from `comparePoint`.

	@param comparePoint Vector3 -- The point to compare from, can be a standalone Vector3 or a part's Vector3
	@param maximumRange number -- The maximum range of which the player's characters have to be within to recieve the event
	@param data ({any} | any)? -- The data that should be sent to each player within `maximumRange`
]=]
function NetworkControllerServer:FireInRange(comparePoint: Vector3, maximumRange: number, data: ({any} | any)?)
	local PlayersToFireTo = { }

	for _, player: Player in PlayerService:GetPlayers() do
		if player:DistanceFromCharacter(comparePoint) <= maximumRange then
			table.insert(PlayersToFireTo, player)
		end
	end

	self:Fire(PlayersToFireTo, data)
end

--[=[
	Recieves an invoke from the server, and runs the callback function which returns some data. Equivalent to [RemoteFunction.OnServerInvoke].

	@param callback (sender: Player, data: {any}) -> (({any} | any)?) -- The callback function to run on invoke, must return at least 1 value.
]=]
function NetworkControllerServer:OnInvoke(callback: (sender: Player, data: {any}) -> (({any} | any)))
	self._Bridge.OnServerInvoke = callback
end

--[=[
	Sets a rate limit that is applied when invoking or firing a network controller from the client.

	@param maxInvokesPerSecond number -- The maximum amount of invokes allowed per second, set to `-1` to disable the rate limit
	@param invokeOverflowCallback ((sender: Player) -> ())? -- The callback function to run when the player has exceeded the current rate limit
]=]
function NetworkControllerServer:SetRateLimit(maxInvokesPerSecond: number, invokeOverflowCallback: ((sender: Player) -> ())?)
	if maxInvokesPerSecond <= -1 then
		self._Bridge:DisableRateLimit()
		return
	end

	if not invokeOverflowCallback then
		return
	end

	self._Bridge:RateLimit(maxInvokesPerSecond, invokeOverflowCallback)
end

--[=[
	Connects a function to the event that is fired when the client fires the network controller. When using `:Once`, the function is only run the first time and then the connection is disconnected automatically.

	@param func (sender: Player, data: {any}) -> () -- The function to call when data is recieved from the client
	@return ControllerConnection
]=]
function NetworkControllerServer:Once(func: (sender: Player, data: {any}?) -> ())
	local Connection = self._Bridge:Once(func)

	table.insert(self._Connections, Connection)
	return Connection
end

--[=[
	Connects a function to the event that is fired when the server fires the network controller.

	@param func (sender: Player, data: {any}) -> () -- The function to call when data is recieved from the server
	@return ControllerConnection
]=]
function NetworkControllerServer:Connect(func: (sender: Player, data: {any}?) -> ())
	local Connection = self._Bridge:Connect(func)

	table.insert(self._Connections, Connection)
	return Connection
end

--[=[
	Yields the current thread until the client fires the network controller.

	@yields
	@return (Player, {any})
]=]
function NetworkControllerServer:Wait(): (Player, {any})
	return self._Bridge:Wait()
end

--[=[
	Disconnects all listeners from the current network controller.
]=]
function NetworkControllerServer:DisconnectAll()
	for _, connection in self._Connections do
		if not connection.Connected then
			continue
		end
		
		connection:Disconnect()
	end
end

--[=[
	Destroys the current network controller.
]=]
function NetworkControllerServer:Destroy()
	self._Bridge:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

-- // Actions

return NetworkController