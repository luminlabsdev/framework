--!strict

-- // Package

local EngineRuntime = { }
local Packages = script.Parent.Parent

-- // Variables

local RunService = game:GetService("RunService")

local Network = require(script.Parent.Network)
local Signal = require(Packages.signal)

local Framework = script.Parent

-- // Engine Context

local EngineRuntimeContext = {
	Studio = RunService:IsStudio(),
	Server = RunService:IsServer(),
	Client = RunService:IsClient(),
	StudioPlay = RunService:IsStudio() and RunService:IsRunning()
}

-- // Engine Settings

-- Signal and NetworkController debugging do not respect studio/live game settings!
local EngineRuntimeSettings = {
	-- Debugging
	StudioDebugging = Framework:GetAttribute("StudioDebugging") :: boolean,
	LiveGameDebugging = Framework:GetAttribute("LiveGameDebugging") :: boolean,
	ShowLoggedEvents = Framework:GetAttribute("ShowLoggedEvents") :: boolean,

	-- Version
	Version = Framework:GetAttribute("Version") :: string,
}

local EngineRuntimeObjects = {
	NetworkControllers = { } :: {[string]: Network.Server<...any> | Network.Client<...any>},
	Signals = { } :: {[string]: Signal.Signal<...any>},
}

-- // Table Assignment

EngineRuntime.Context = table.freeze(EngineRuntimeContext)
EngineRuntime.Settings = table.freeze(EngineRuntimeSettings)
EngineRuntime.Objects = table.freeze(EngineRuntimeObjects)

return table.freeze(EngineRuntime)