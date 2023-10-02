-- // Package

local SignalController = { }
SignalController.__index = SignalController

-- // Variables

local EngineVendor = script.Parent.Parent.Parent.Parent
local EngineLibraries = EngineVendor.Libraries

local Signal = require(EngineLibraries.RedbloxUtils.Signal)
local Sanitize = require(script.Parent.Parent.Sanitize)

-- // Functions

function SignalController.CreateController(name: string)
	local self = setmetatable({ }, SignalController)
	
	self._Signal = Signal()
	self.Connections = { }
	self.Name = name
	
	return self
end

function SignalController:Fire(data: ({any} | any)?)
	self._Signal:Fire(Sanitize(data))
end

function SignalController:Connect(func: (data: {any}?) -> ())
	local Connection = self._Signal:Connect(func)
	table.insert(self.Connections, Connection)
	return Connection
end

function SignalController:Once(func: (data: {any}?) -> ())
	local ConnectionToDisconnect

 	ConnectionToDisconnect = self._Signal:Connect(function(data)
		ConnectionToDisconnect()
		func(data)
	end)
	
	table.insert(self.Connections, ConnectionToDisconnect)
	return ConnectionToDisconnect
end

function SignalController:Wait(): {any}?
	return self._Signal:Wait()
end

function SignalController:DisconnectAll()
	self._Signal:DisconnectAll()
end

-- // Connections

-- // Actions

return table.freeze(SignalController)