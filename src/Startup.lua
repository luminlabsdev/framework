-- // Package

local Package = { }

-- // Variables

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")

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

function Package.StartEngine(): number?
	local currentTime = os.clock()
	-- Check if it's already running
	if CanaryEngineRuntime.IsStarted() then
		return nil
	end

	if not RuntimeContext.Server then
		return nil
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
	
	if not UserScripts.Server:FindFirstChildWhichIsA("Script") then
		CanaryEngineDebugger.print("At least one server script inside of the scripts folder is required.")
	end
	
	local TimeTaken = os.clock() - currentTime

	CanaryEngineDebugger.print(`CanaryEngine loaded successfully! ({TimeTaken * 1000}ms)`)
	CanaryEngineModule:SetAttribute("EngineStarted", true)
	
	return TimeTaken
end

-- // Actions

return Package
