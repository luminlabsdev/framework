-- // Package

local Package = { }

-- // Variables

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local EngineMain = ReplicatedStorage.CanaryEngine

local IsStudio = RunService:IsStudio()
local console = require(script.Parent.Console)

local StudioDebuggerEnabled = EngineMain.EngineManager:GetAttribute("StudioDebuggerEnabled")

local ParentTypes = {
	Client = ReplicatedStorage;
	Global = ReplicatedStorage;
	Server = ServerStorage;
}
 
-- // Functions

function Package.SetupFolders(setupType: "Server" | "Global" | "Client")
	local EngineFolder = Instance.new("Folder")
	
	EngineFolder.Name = "Engine" .. setupType
	
	local UserPackages = EngineMain.Packages
	local UserAssets = EngineMain.Media
	
	local NewPackages: Folder = UserPackages[setupType]
	
	if setupType ~= "Global" then
		local NewAssets: Folder = UserAssets[setupType]
		
		NewAssets.Name = "Assets"
		NewAssets.Parent = EngineFolder
	end
	
	NewPackages.Name = "Packages"
	NewPackages.Parent = EngineFolder
	
	EngineFolder.Parent = ParentTypes[setupType]
end

function Package.FinalizeSetup()
	local Scripts = EngineMain.Scripts

	Scripts.Name = "EngineScripts"
	Scripts.Parent = ReplicatedStorage
	
	for index, value in ipairs(EngineMain:GetChildren()) do
		if value.Name ~= "EngineManager" then
			value:Destroy()
		end
	end
	
	if IsStudio and StudioDebuggerEnabled then
		console.log("Startup finalized.")
	end
end

-- // Actions

return Package
