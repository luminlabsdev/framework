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
	Global = ReplicatedStorage;
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
	local UserAssets = CanaryEngineFolder.Media
	local UserScripts = CanaryEngineFolder.Scripts
	
	-- Loop through available setup types
	for setupType, parentType in pairs(ParentTypes) do
		local EngineFolder = Instance.new("Folder")

		EngineFolder.Name = `Engine{setupType}`

		local NewPackages: Folder = UserPackages[setupType]

		if setupType ~= "Global" then
			local NewMedia: Folder = UserAssets[setupType]

			NewMedia.Name = "Media"
			NewMedia.Parent = EngineFolder
		end

		NewPackages.Name = "Packages"
		NewPackages.Parent = EngineFolder

		EngineFolder.Parent = parentType
	end
	-- Finalize setup
	
	UserScripts.Name = "EngineScripts"
	UserScripts.Parent = ReplicatedStorage

	for index, value in ipairs(CanaryEngineFolder:GetChildren()) do
		if value.Name ~= "CanaryEngine" then
			value:Destroy()
		end
	end

	CanaryEngineDebugger.print("Framework loaded successfully!")

	CanaryEngineModule:SetAttribute("EngineStarted", true)
end

-- // Actions

return Package
