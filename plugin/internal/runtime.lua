local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CanaryEngineFramework = ReplicatedStorage.CanaryEngineFramework

return {
	Context = {
		Studio = RunService:IsStudio();
		Server = RunService:IsServer();
		Client = RunService:IsClient();
		StudioPlay = RunService:IsRunning();
	},
	
	Settings = {
		StudioDebugEnabled = CanaryEngineFramework:GetAttribute("StudioDebugger");
		CheckLatestVersion = CanaryEngineFramework:GetAttribute("CheckLatestVersion");
		LiveGameDebugger = CanaryEngineFramework:GetAttribute("LiveGameDebugger");
	},
	
	IsStarted = function(): boolean
		return CanaryEngineFramework.CanaryEngine:GetAttribute("Started")
	end,
}