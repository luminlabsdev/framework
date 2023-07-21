-- // Package

--[=[
	The parent of all classes.

	@class NetworkController
]=]
local SignalController = { }

--[=[
	The SignalControllerObject class.

	@client
	@class SignalControllerObject
]=]
local SignalControllerObject = { }

--[=[
	The name of the the signal controller.

	@readonly

	@prop Name string
	@within SignalControllerObject
]=]

--[=[
	The signal for use in Signal.

	@readonly
	@private

	@prop _Signal ScriptSignal<any>
	@within SignalControllerObject
]=]

local ControllerIndex = {__index = SignalControllerObject}

-- // Variables

local Signal = require(script.Vendor.Signal)
local Controllers = require(script.Parent.Parent)

-- // Functions

--[=[
	Creates a new signal controller.

	@ignore

	@param name string -- The name of the new controller
	@return SignalControllerObject
]=]
function SignalController.NewController(name: string)
	local self = setmetatable({ }, ControllerIndex)
	
	self._Signal = Signal.new()
	self.Name = name
	
	return self
end

--[=[
	Fires an event which sends data to another script that is connected to it, equivalent to [BindableEvent:Fire]

	:::tip

	If you're firing a single piece of data, there is no need to wrap it in a table!

	```lua
	SignalController:Fire("Hello, world!")
	```

	:::

	@param data ({any} | any)? -- The data that should be sent the other script
]=]
function SignalControllerObject:Fire(data: ({any} | any)?)
	self._signalMain:Fire(Controllers.SanitizeData(data))
end

--[=[
	Connects a function to the event that is fired when another script fires the controller.

	@param func (data: {any}) -> () -- The function to call when data is recieved
	@return ScriptConnection
]=]
function SignalControllerObject:Connect(func: (data: {any}?) -> ())
	return self._signalMain:Connect(func)
end

--[=[
	Connects a function to the event that is fired when another script fires the controller. When using `:Once`, the function is only run the first time and then the connection is disconnected automatically.

	@param func (data: {any}) -> () -- The function to call when data is recieved
	@return ScriptConnection
]=]
function SignalControllerObject:Once(func: (data: {any}?) -> ())
	return self._signalMain:Once(func)
end

--[=[
	Yields the current thread until another script fires the signal controller.

	@yields
	@return {any}
]=]
function SignalControllerObject:Wait(): {any}?
	return self._signalMain:Wait()
end

--[=[
	Disconnects all listeners from the current signal controller.
]=]
function SignalControllerObject:DisconnectAll()
	self._signalMain:DisconnectAll()
end

-- // Connections

-- // Actions

return SignalController
