-- // Variables

if not plugin then
	return
end

local IsLocal = if string.find(plugin.Name, ".rbxm") or string.find(plugin.Name, ".lua") then true else false
local PluginToolbarName = if IsLocal then "Canary Studio - Local File" else "Canary Studio"

local PluginVersion = 8
local AssetId = 12591143042
local PluginToolbar = plugin:CreateToolbar(PluginToolbarName)

local CanaryStudio = PluginToolbar:CreateButton("Canary Studio", "Canary Studio", "rbxassetid://12805094224")
local CreateInstances = PluginToolbar:CreateButton("Create Instances", "Create new packages and scripts.", "rbxassetid://12590602896")
local MigrateVersion = PluginToolbar:CreateButton("Migrate", "Migrate CanaryEngine to the latest version while keeping packages, scripts, and media saved.", "rbxassetid://12590988996")
local InstallFramework = PluginToolbar:CreateButton("Install", "Get a clean and fresh install of CanaryEngine.", "rbxassetid://12663166329")
local UninstallFramework = PluginToolbar:CreateButton("Uninstall", "Correctly uninstall CanaryEngine.", "rbxassetid://12672999217")
local InstallDefaultPackages = PluginToolbar:CreateButton("Install Default Packages", "Install all of the default packages.", "rbxassetid://13036493778")

local CreateInstancesMenu: PluginMenu = plugin:CreatePluginMenu(7282)

local CreatePackagesMenu: PluginMenu = plugin:CreatePluginMenu(5715, "Create Package", "rbxassetid://12663138861")
local CreateScriptsMenu: PluginMenu = plugin:CreatePluginMenu(6780, "Create Script", "rbxassetid://12805308379")

CreatePackagesMenu:AddNewAction("CreateServerPackage", "Server Package", "rbxassetid://12797058908")
CreatePackagesMenu:AddNewAction("CreateReplicatedPackage", "Replicated Package", "rbxassetid://12797063481")
CreatePackagesMenu:AddNewAction("CreateClientPackage", "Client Package", "rbxassetid://12797061582")

CreateScriptsMenu:AddNewAction("CreateClientScript", "Client Script", "rbxassetid://12797061582")
CreateScriptsMenu:AddNewAction("CreateServerScript", "Server Script", "rbxassetid://12797058908")

CreateInstancesMenu:AddMenu(CreatePackagesMenu)
CreateInstancesMenu:AddMenu(CreateScriptsMenu)

InstallDefaultPackages.ClickableWhenViewportHidden = true
CreateInstances.ClickableWhenViewportHidden = true
MigrateVersion.ClickableWhenViewportHidden = true
InstallFramework.ClickableWhenViewportHidden = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local InsertService = game:GetService("InsertService")
local Selection = game:GetService("Selection")
local ScriptEditorService = game:GetService("ScriptEditorService")

local PluginTools = require(script.Vendor.PluginTools)

local DefaultPackages = script.Assets.Default

local ScriptSources = {
	Server = [[
-- // Engine

local CanaryEngine = require(game:GetService("ReplicatedStorage"):WaitForChild("CanaryEngineFramework").CanaryEngine)
local EngineServer = CanaryEngine.GetEngineServer()

local Packages = EngineServer.Packages
local Media = EngineServer.Media

-- // Constants

-- // Variables

-- // Functions

local function myFunction()
	print("Hello, function!")
end

-- // Connections

-- // Actions

print("Hello, server!")
	]];
	
	Client = [[
-- // Engine

local CanaryEngine = require(game:GetService("ReplicatedStorage"):WaitForChild("CanaryEngineFramework").CanaryEngine)
local EngineClient = CanaryEngine.GetEngineClient()

local Packages = EngineClient.Packages
local Media = EngineClient.Media

-- // Constants

-- // Variables

-- // Functions

local function myFunction()
	print("Hello, function!")
end

-- // Connections

-- // Actions

print("Hello, client!")
	]]
}

-- // Functions

local function CreateScript(scriptType: "Server" | "Client")
	local ParentedFramework = PluginTools.GetParentedFramework()

	if not ParentedFramework or not PluginTools.IsInstalled() then
		warn("CanaryEngine must be installed correctly before creating new objects.")
		return
	end
	
	local NewScript = Instance.new("Script")

	NewScript.Name = `{scriptType}Script`
	NewScript.RunContext = Enum.RunContext[scriptType]
	NewScript.Source = ScriptSources[scriptType]

	NewScript.Parent = ParentedFramework.Scripts[scriptType]
	NewScript.Enabled = true
	
	ScriptEditorService:OpenScriptDocumentAsync(NewScript)
	Selection:Set({NewScript})
end

local function CreatePackage(packageType: "Server" | "Client" | "Replicated")
	local ParentedFramework = PluginTools.GetParentedFramework()

	if not ParentedFramework or not PluginTools.IsInstalled() then
		warn("CanaryEngine must be installed correctly before creating new objects.")
		return
	end
	
	local PackageVendor = Instance.new("Folder")
	local ClonedPackage = script.Assets[`{packageType}Package`]:Clone()
	
	PackageVendor.Name = "Vendor"
	ClonedPackage.Name = `{packageType}Package`
	ClonedPackage.Parent = ParentedFramework.Packages[packageType]
	PackageVendor.Parent = ClonedPackage
	
	ScriptEditorService:OpenScriptDocumentAsync(ClonedPackage)
	Selection:Set({ClonedPackage})
end

local Actions = {
	CreateServerPackage = function()
		CreatePackage("Server")
	end,
	
	CreateClientPackage = function()
		CreatePackage("Client")
	end,
	
	CreateReplicatedPackage = function()
		CreatePackage("Replicated")
	end,
	
	CreateClientScript = function()
		CreateScript("Client")
	end,
	
	CreateServerScript = function()
		CreateScript("Server")
	end,
}

CreateInstances.Click:Connect(function()
	local selectedAction = CreateInstancesMenu:ShowAsync()
	
	if selectedAction then
		Actions[string.split(selectedAction.ActionId, "_")[3]]()
	end
end)

MigrateVersion.Click:Connect(function()
	if not PluginTools.IsInstalled() then
		warn("CanaryEngine must be installed correctly before migrating to a newer version.")
		return
	end
	
	local ParentedFramework = PluginTools.GetParentedFramework()
	
	ParentedFramework:SetAttribute("VersionNumber", PluginVersion)
	ParentedFramework:SetAttribute("PackageId", AssetId)
	
	PluginTools.SetEngineModuleParent(PluginTools.GetCloneOfEngineModule())
	ChangeHistoryService:SetWaypoint("MigrateCanaryEngine")
end)

InstallFramework.Click:Connect(function()
	PluginTools.InstallFramework()
	ChangeHistoryService:SetWaypoint("InstallCanaryEngine")
end)

UninstallFramework.Click:Connect(function()
	local UninstallConfirmation = Instance.new("BoolValue")
	local OldInstall = PluginTools.GetParentedFramework()
	
	if not PluginTools.IsInstalled() or not OldInstall then
		warn("CanaryEngine must be installed correctly before uninstalling it.")
		return
	end
	
	UninstallConfirmation:GetPropertyChangedSignal("Value"):Once(function()
		if UninstallConfirmation.Value then
			OldInstall:Destroy()
			UninstallConfirmation:Destroy()
		end
	end)
	
	UninstallConfirmation.Parent = game
	UninstallConfirmation.Name = "Uninstall CanaryEngine?"
	
	Selection:Set({UninstallConfirmation})
	Selection.SelectionChanged:Once(function()
		UninstallConfirmation:Destroy()
	end)
	
	ChangeHistoryService:SetWaypoint("UninstallCanaryEngine")
end)

InstallDefaultPackages.Click:Connect(function()
	local ParentedFramework = PluginTools.GetParentedFramework()
	
	if not PluginTools.IsInstalled() or not ParentedFramework then
		warn("CanaryEngine must be installed correctly before creating new objects.")
	end
	
	for index, value in DefaultPackages:GetChildren() do
		for _, Package in value:GetChildren() do
			local Parent = Package.Parent.Name
			local ClonedPackage = Package:Clone()
			
			ClonedPackage.Parent = ParentedFramework.Packages[Parent]
		end
	end
end)

-- // Actions

PluginTools.IsInstalled()
