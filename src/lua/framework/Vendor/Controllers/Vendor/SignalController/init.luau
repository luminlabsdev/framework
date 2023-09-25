-- // Package

local SignalController = { }
local SignalControllerObject = { }

SignalController.__index = SignalControllerObject

-- // Variables

local EngineVendor = script.Parent.Parent.Parent.Parent
local EngineLibraries = EngineVendor.Libraries

local Signal = require(EngineLibraries.RedbloxUtils.Signal)
local Sanitize = require(script.Parent.Parent.Sanitize)

-- // Functions

function SignalController.CreateController(name: string)
	local self = setmetatable({ }, SignalControllerObject)
	
	self._Signal = Signal()
	self.Name = name
	
	return self
end

function SignalControllerObject:Fire(data: ({any} | any)?)
	self._Signal:Fire(Sanitize(data))
end

function SignalControllerObject:Connect(func: (data: {any}?) -> ())
	return self._Signal:Connect(func)
end

function SignalControllerObject:Once(func: (data: {any}?) -> ())
	local Disconnect

	Disconnect = self._Signal:Connect(function(data)
		Disconnect()
		func(data)
	end)

	return Disconnect
end

function SignalControllerObject:Wait(): {any}?
	return self._Signal:Wait()
end

function SignalControllerObject:DisconnectAll()
	self._Signal:DisconnectAll()
end

-- // Connections

-- // Actions

return SignalController