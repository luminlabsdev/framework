local RunService = game:GetService("RunService")
local CanaryEngineFramework = game:GetService("ReplicatedStorage").CanaryEngineFramework

--[=[
	The parent of all classes.

	@class EngineRuntime
]=]
local EngineRuntime = { }

--[=[
	Shows different runtime contexts.

	@prop Context {[string]: boolean}
	@within EngineRuntime
]=]

--[=[
	Shows different runtime settings.

	@prop Settings {[string]: boolean | string | number}
	@within EngineRuntime
]=]

--[=[
	The parent of all classes.

	@class EngineRuntimeContext
]=]
local EngineRuntimeContext = {
	Studio = RunService:IsStudio(),
	Server = RunService:IsServer(),
	Client = RunService:IsClient(),
	StudioPlay = RunService:IsStudio() and RunService:IsRunning()
}

--[=[
	The parent of all classes.

	@class EngineRuntimeSettings
]=]
local EngineRuntimeSettings = {
	StudioDebugEnabled = CanaryEngineFramework:GetAttribute("StudioDebugger"),
	LiveGameDebugEnabled = CanaryEngineFramework:GetAttribute("LiveGameDebugger"),
	Version = CanaryEngineFramework:GetAttribute("Version"),
}

--[=[
	Whether or not if `StudioDebugger` is enabled

	@prop StudioDebugEnabled boolean
	@within EngineRuntimeSettings
]=]

--[=[
	Whether or not if `LiveGameDebugger` is enabled
	
	@prop LiveGameDebugEnabled boolean
	@within EngineRuntimeSettings
]=]

--[=[
	The current version of CanaryEngine.
	
	@prop Version string
	@within EngineRuntimeSettings
]=]

EngineRuntime.Context = EngineRuntimeContext
EngineRuntime.Settings = EngineRuntimeSettings

return EngineRuntime