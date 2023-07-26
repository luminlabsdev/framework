local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CanaryEngineFramework = ReplicatedStorage.CanaryEngineFramework

return {
	Context = {
		Studio = RunService:IsStudio(),
		Server = RunService:IsServer(),
		Client = RunService:IsClient(),
		StudioPlay = RunService:IsRunning(),
		StudioEdit = RunService:IsEdit(),
	},
	
	Settings = {
		StudioDebugEnabled = CanaryEngineFramework:GetAttribute("StudioDebugger"),
		LiveGameDebugger = CanaryEngineFramework:GetAttribute("LiveGameDebugger"),
		Version = CanaryEngineFramework:GetAttribute("Version"),
	},
}