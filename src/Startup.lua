-- // Package

local Package = { }

-- // Variables

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local CanaryEngineFolder = ReplicatedStorage.CanaryEngineFramework
local CanaryEngineModule = script.Parent
local CanaryEngineDebugger = require(script.Parent.Debugger)
local CanaryEngineRuntime = require(script.Parent.Runtime)

local RuntimeContext = CanaryEngineRuntime.Context
local RuntimeSettings = CanaryEngineRuntime.Settings

local ParentTypes = {
	Client = ReplicatedStorage;
	Replicated = ReplicatedStorage;
	Server = ServerStorage;
}
 
-- // Functions

function Package.StartEngine()
	-- Check if it's already running
	if CanaryEngineRuntime.IsStarted() then
		return
	end

	if not RuntimeContext.Server then
		return
	end
	
	local UserPackages = CanaryEngineFolder.Packages
	local UserMedia = CanaryEngineFolder.Media
	local UserScripts = CanaryEngineFolder.Scripts
	
	-- Loop through available setup types
	for setupType, parentType in ParentTypes do
		local EngineFolder = Instance.new("Folder")

		EngineFolder.Name = `Engine{setupType}`
		
		local NewPackages: Folder = UserPackages[setupType]

		NewPackages.Name = "Packages"
		NewPackages.Parent = EngineFolder

		if setupType ~= "Replicated" then
			local NewMedia: Folder = UserMedia[setupType]
			
			NewMedia.Name = "Media"
			NewMedia.Parent = EngineFolder
		end

		EngineFolder.Parent = parentType
	end
	-- Finalize setup
	
	UserScripts.Name = "EngineScripts"
	UserScripts.Parent = ReplicatedStorage

	for index, value in CanaryEngineFolder:GetChildren() do
		if value.Name ~= "CanaryEngine" then
			value:Destroy()
		end
	end

	CanaryEngineDebugger.print("Framework loaded successfully!")

	CanaryEngineModule:SetAttribute("EngineStarted", true)
end

-- // Actions

return Package
