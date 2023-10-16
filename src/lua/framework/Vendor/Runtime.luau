-- // Package

local EngineRuntime = { }

local RunService = game:GetService("RunService")
local Framework = game:GetService("ReplicatedStorage").Framework

local Network = require(script.Parent.Network.Init)
local Signal = require(script.Parent.Libraries.RedbloxUtils.Signal)

-- Engine Context

local EngineRuntimeContext = {
	Studio = RunService:IsStudio(),
	Server = RunService:IsServer(),
	Client = RunService:IsClient(),
	StudioPlay = RunService:IsStudio() and RunService:IsRunning()
}

-- Engine Settings

local EngineRuntimeSettings = {
	StudioDebugEnabled = Framework:GetAttribute("StudioDebugging"),
	LiveGameDebugEnabled = Framework:GetAttribute("LiveGameDebugging"),
	Version = Framework:GetAttribute("Version"),
}

local EngineRuntimeObjects = {
	NetworkControllers = { } :: Network.Server<...any> | Network.Client<...any>,
	Signals = { } :: Signal.Signal<...any>,
}

-- Table Assignment

EngineRuntime.Context = EngineRuntimeContext
EngineRuntime.Settings = EngineRuntimeSettings
EngineRuntime.Objects = table.freeze(EngineRuntimeObjects)

return table.freeze(EngineRuntime)