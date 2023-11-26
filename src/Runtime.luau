--!strict

-- // Package

local Runtime = { }
local Packages = script.Parent.Parent

-- // Variables

local RunService = game:GetService("RunService")

local Network = require(script.Parent.Network)
local Signal = require(Packages.signal)

local Framework = script.Parent

-- // Context

local RuntimeContext = {
	Studio = RunService:IsStudio(),
	Server = RunService:IsServer(),
	Client = RunService:IsClient(),
	StudioPlay = RunService:IsStudio() and RunService:IsRunning()
}

-- // Settings

-- Signal and NetworkController debugging do not respect studio/live game settings!
local RuntimeSettings = {
	-- Debugging
	StudioDebugging = Framework:GetAttribute("StudioDebugging") :: boolean,
	LiveGameDebugging = Framework:GetAttribute("LiveGameDebugging") :: boolean,
	ShowLoggedEvents = Framework:GetAttribute("ShowLoggedEvents") :: boolean,

	-- Version
	Version = Framework:GetAttribute("Version") :: string,
}

local RuntimeObjects = {
	NetworkControllers = { } :: {[string]: Network.Server<...any> | Network.Client<...any>},
	Signals = { } :: {[string]: Signal.Signal<...any>},
}

-- // Table Assignment

Runtime.Context = table.freeze(RuntimeContext)
Runtime.Settings = table.freeze(RuntimeSettings)
Runtime.Objects = table.freeze(RuntimeObjects)

return table.freeze(Runtime)