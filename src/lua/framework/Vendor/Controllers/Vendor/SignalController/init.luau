-- // Package

--[=[
	The parent of all classes.

	@ignore
	@class SignalController
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

	@prop _Signal SignalController<any>
	@within SignalControllerObject
]=]

SignalController.__index = SignalControllerObject

-- // Variables

local EngineVendor = script.Parent.Parent.Parent.Parent
local EngineLibraries = EngineVendor.Libraries

local Signal = require(EngineLibraries.RedbloxUtils.Signal)
local Sanitize = require(script.Parent.Parent.Sanitize)

-- // Functions

--[=[
	Creates a new signal controller.
	
	@param name string -- The name of the new controller
	@return SignalControllerObject
]=]
function SignalController.NewController(name: string)
	local self = setmetatable({ }, SignalControllerObject)
	
	self._Signal = Signal()
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
	self._Signal:Fire(Sanitize(data))
end

--[=[
	Connects a function to the event that is fired when another script fires the controller.

	@param func (data: {any}) -> () -- The function to call when data is recieved
	@return ControllerConnection
]=]
function SignalControllerObject:Connect(func: (data: {any}?) -> ())
	return self._Signal:Connect(func)
end

--[=[
	Connects a function to the event that is fired when another script fires the controller. When using `:Once`, the function is only run the first time and then the connection is disconnected automatically.

	@param func (data: {any}) -> () -- The function to call when data is recieved
	@return ControllerConnection
]=]
function SignalControllerObject:Once(func: (data: {any}?) -> ())
	local Disconnect

	Disconnect = self._Signal:Connect(function(data)
		Disconnect()
		func(data)
	end)

	return Disconnect
end

--[=[
	Yields the current thread until another script fires the signal controller.

	@yields
	@return {any}
]=]
function SignalControllerObject:Wait(): {any}?
	return self._Signal:Wait()
end

--[=[
	Disconnects all listeners from the current signal controller.
]=]
function SignalControllerObject:DisconnectAll()
	self._Signal:DisconnectAll()
end

-- // Connections

-- // Actions

return SignalController