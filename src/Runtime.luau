-- // Package

local Runtime = { }

-- // Variables

local Network = require(script.Parent.Network)
local Signal = require(script.Parent.Parent.signal)

local Framework = script.Parent

-- // Settings

-- Signal and NetworkController debugging do not respect studio/live game settings!
local RuntimeSettings = {
	-- Debugging
	ShowLoggedEvents = Framework:GetAttribute("StudioShowLoggedEvents") :: boolean,

	-- Network
	IgnoreInvalidNetworkArgs = Framework:GetAttribute("IgnoreInvalidNetworkArgs") :: boolean, -- Only recommended to be disabled during tests!

	-- Version
	Version = Framework:GetAttribute("Version") :: string,
}

local RuntimeObjects = {
	NetworkControllers = { } :: {[string]: Network.Server<...any> | Network.Client<...any>}, -- Table is different for each client and the server
	Signals = { } :: {[string]: Signal.Signal<...any>},
}

-- // Assignment

Runtime.Settings = table.freeze(RuntimeSettings)
Runtime.Objects = table.freeze(RuntimeObjects)

return table.freeze(Runtime)