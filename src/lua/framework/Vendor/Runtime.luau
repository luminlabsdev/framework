-- // Package

local EngineRuntime = { }

local RunService = game:GetService("RunService")
local Framework = game:GetService("ReplicatedStorage").Framework

-- Engine Context

local EngineRuntimeContext = {
	Studio = RunService:IsStudio(),
	Server = RunService:IsServer(),
	Client = RunService:IsClient(),
	StudioPlay = RunService:IsStudio() and RunService:IsRunning()
}

-- Engine Settings

local EngineRuntimeSettings = {
	StudioDebugEnabled = Framework:GetAttribute("StudioDebugger"),
	LiveGameDebugEnabled = Framework:GetAttribute("LiveGameDebugger"),
	Version = Framework:GetAttribute("Version"),
}

-- Table Assignment

EngineRuntime.Context = EngineRuntimeContext
EngineRuntime.Settings = EngineRuntimeSettings

return table.freeze(EngineRuntime)