-- // Package

--[=[
	The parent of all classes.

	@class EngineRuntime
]=]
local EngineRuntime = { }

local RunService = game:GetService("RunService")
local Framework = game:GetService("ReplicatedStorage").Framework

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
	Whether the current client is connected to studio.

	@prop Studio boolean
	@within EngineRuntimeContext
]=]

--[=[
	Whether the current environment is the server.

	@prop Server boolean
	@within EngineRuntimeContext
]=]

--[=[
	Whether the current environment is the client.

	@prop Client boolean
	@within EngineRuntimeContext
]=]

--[=[
	Whether the current client is playtesting in studio.

	@prop StudioPlay boolean
	@within EngineRuntimeContext
]=]

--[=[
	The parent of all classes.

	@class EngineRuntimeSettings
]=]
local EngineRuntimeSettings = {
	StudioDebugEnabled = Framework:GetAttribute("StudioDebugger"),
	LiveGameDebugEnabled = Framework:GetAttribute("LiveGameDebugger"),
	Version = Framework:GetAttribute("Version"),
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