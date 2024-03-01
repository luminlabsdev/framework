-- // Package

local Runtime = {}

-- // Variables

local Event = require(script.Parent.Parent.event)
local Framework = script.Parent

-- // Settings

-- Signal and NetworkController debugging do not respect studio/live game settings!
local RuntimeSettings = {
	ShowLoggedEvents = Framework:GetAttribute("StudioShowLoggedEvents") :: boolean,
	IgnoreInvalidNetworkArgs = Framework:GetAttribute("IgnoreInvalidNetworkArgs") :: boolean, -- Only recommended to be disabled during tests!
	Version = Framework:GetAttribute("Version") :: string,
}

local RuntimeObjects = {
	Network = {Event = {}, Function = {}} :: {
		Event: {[string]: any},
		Function: {[string]: any},
	}, -- Tables inside are different for each client and the server
	Signals = {} :: {[string]: Event.Signal<...any>},
}

-- // Assignment

Runtime.Settings = table.freeze(RuntimeSettings)
Runtime.Objects = table.freeze(RuntimeObjects)

return table.freeze(Runtime)