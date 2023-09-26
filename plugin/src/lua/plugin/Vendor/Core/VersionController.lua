--!nocheck

-- // Variables

local VersionController = { }

local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptEditorService = game:GetService("ScriptEditorService")
local SelectionService = game:GetService("Selection")

local Vendor = script.Parent.Parent

local TableKit = require(Vendor.TableKit)
local WindowList = require(Vendor.Core.WindowList)
local WindowController = require(Vendor.Core.WindowController)(WindowList)
local Fetch = require(Vendor.Fetch)
local Signal = require(Vendor.Signal)
local HttpCache = require(Vendor.Core.HttpCache)
local CanaryStudioSettings = require(Vendor.Settings.Settings)

local FinishedFiles = 0
local TotalPackageFiles = 0
local UpdateDebounce = false
local FrameworkPackages = Vendor.FrameworkPackages
local StructureCache = Vendor.StructureCache
local PackageInstallCache = Vendor.InstallPackageCache

local ERROR_COLOR = Color3.fromRGB(255, 129, 129)
local UPDATE_COOLDOWN_SECONDS = 30

local RequiredEngineInstances = {
	"Server",
	"Client",
	"Replicated",
	"Framework",
	"ReplicatedFirst",
}

local FolderToService = {
	EngineClient = ReplicatedStorage,
	EngineReplicated = ReplicatedStorage,
	EngineReplicatedFirst = ReplicatedFirst,
	EngineServer = ServerStorage,
}

VersionController.DataUpdated = Signal.new()

-- // Functions

function VersionController.GetDirectoryFromStructureJSON(json: {any}, parent: Instance, isPackage: boolean?)
	for instanceName, children in json do
		if instanceName == "$parent" then
			continue
		end

		if type(instanceName) == "string" and type(children) == "string" then
			local InstanceToGet = FrameworkPackages:FindFirstChild(children)

			if not InstanceToGet then
				continue
			end

			local InstanceToGetClone = InstanceToGet:Clone()

			InstanceToGetClone.Name = instanceName
			InstanceToGetClone.Parent = parent

			continue
		end

		local InstanceFromClass: Instance

		if instanceName ~= "$properties" then
			InstanceFromClass = Instance.new(children["$className"] or "Folder")
			InstanceFromClass.Name = instanceName
			InstanceFromClass.Parent = parent
		end

		if children["$properties"] then
			for propertyName: string, propertyValue: string | any in children["$properties"] do
				if propertyName == "Source" and propertyValue:find("https://") then
					local Source = Fetch.FetchAsync(propertyValue, false)

					if not Source then
						continue
					end

					if not isPackage then
						FinishedFiles += 1
						VersionController.DataUpdated:Fire(FinishedFiles, HttpCache.ExternalSettings.Files, "Updating ", "Updating framework to latest version")
					end

					InstanceFromClass[propertyName] = Source
				elseif type(propertyName) == "string" then
					InstanceFromClass[propertyName] = propertyValue
				end
			end
		end

		if type(children) == "table" and not TableKit.IsEmpty(children) then
			VersionController.GetDirectoryFromStructureJSON(children, InstanceFromClass, isPackage)
		end
	end
end

function VersionController.GetCurrentInstance(ignoreNil: boolean?): {[string]: Folder}?
	ignoreNil = ignoreNil or false

	local EngineTable = {
		Server = ServerStorage:FindFirstChild("EngineServer"),
		Client = ReplicatedStorage:FindFirstChild("EngineClient"),
		Replicated = ReplicatedStorage:FindFirstChild("EngineReplicated"),
		Framework = ReplicatedStorage:FindFirstChild("Framework") or ReplicatedStorage:FindFirstChild("CanaryEngineFramework"),
		ReplicatedFirst = ReplicatedFirst:FindFirstChild("EngineReplicatedFirst")
	}

	if not ignoreNil then
		for _, value in RequiredEngineInstances do
			if not EngineTable[value] then
				return nil
			end
		end
	end

	if TableKit.IsEmpty(EngineTable) then
		return nil
	end

	return EngineTable
end

function VersionController.UninstallFramework()
	local CurrentInstance = VersionController.GetCurrentInstance(true)

	if not CurrentInstance then
		WindowController.SetMessageWindow("Framework is not installed; cannot uninstall")
		return
	end

	for _, instancePart in CurrentInstance do
		instancePart:Destroy()
	end
	
	ReplicatedFirst:SetAttribute("EngineLoaderEnabled", nil)
end

function VersionController.UpdateFramework()
	local CurrentInstance = VersionController.GetCurrentInstance(true)

	if not CurrentInstance then
		WindowController.SetMessageWindow("Framework is not installed; cannot update")
		return
	end

	if CurrentInstance.Framework and not (CurrentInstance.Client or CurrentInstance.Server or CurrentInstance.ReplicatedFirst or CurrentInstance.Replicated) then
		WindowController.SetMessageWindow("An old version of the framework is installed, and older versions are no longer supported. You will have to update manually.", ERROR_COLOR)
		return
	end

	if UpdateDebounce then
		WindowController.SetMessageWindow("You're trying to install/update too fast! Please wait 30 seconds between each install or update", ERROR_COLOR)
		return
	end

	UpdateDebounce = true

	task.defer(function()
		StructureCache:ClearAllChildren()
		WindowController.SetWindow("UpdateStatusWindow", true)
		VersionController.GetDirectoryFromStructureJSON(
			Fetch.FetchAsync("https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/src/json/structure.json", true),
			StructureCache
		)

		for instanceName, parentType in FolderToService do
			local InstanceToFind = StructureCache:FindFirstChild(instanceName)

			if not parentType:FindFirstChild(instanceName) and InstanceToFind then
				InstanceToFind.Parent = parentType
			end
		end

		local CanaryEngineStructure = StructureCache.Framework
		local EngineLoaderStructure = StructureCache.EngineReplicatedFirst.Framework

		if CurrentInstance.Framework then
			CurrentInstance.Framework:Destroy()
			CurrentInstance.Framework = CanaryEngineStructure
			
			CanaryEngineStructure:SetAttribute("Version", HttpCache.ReleaseLatest.tag_name)
			CanaryEngineStructure.Parent = ReplicatedStorage
		end
		
		if CurrentInstance.ReplicatedFirst then
			CurrentInstance.ReplicatedFirst.Framework:Destroy()
			EngineLoaderStructure.Parent = CurrentInstance.ReplicatedFirst
		end
		
		if not ReplicatedFirst:GetAttribute("EngineLoaderEnabled") then
			ReplicatedFirst:SetAttribute("EngineLoaderEnabled", false)
		end

		WindowController.SetWindow("UpdateStatusWindow", false)
		WindowController.SetMessageWindow("Framework updated successfully!", Color3.fromRGB(205, 255, 151))

		task.wait(UPDATE_COOLDOWN_SECONDS)
		UpdateDebounce = false
		FinishedFiles = 0
		VersionController.DataUpdated:Fire(FinishedFiles, 1, "nil", "nil")
	end)
end

function VersionController.InstallFramework()
	if VersionController.GetCurrentInstance(true) then
		WindowController.SetMessageWindow("Framework is already installed; cannot install")
		return
	end

	if UpdateDebounce then
		WindowController.SetMessageWindow("You're trying to install/update too fast! Please wait 30 seconds between each install or update", ERROR_COLOR)
		return
	end

	UpdateDebounce = true

	task.defer(function()
		StructureCache:ClearAllChildren()
		WindowController.SetWindow("UpdateStatusWindow", true)
		VersionController.GetDirectoryFromStructureJSON(
			Fetch.FetchAsync("https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/src/json/structure.json", true),
			StructureCache
		)

		for instanceName, parentType in FolderToService do
			local InstanceToFind = StructureCache:FindFirstChild(instanceName)

			if not parentType:FindFirstChild(instanceName) and InstanceToFind then
				InstanceToFind.Parent = parentType
			end
		end

		StructureCache.Framework:SetAttribute("Version", HttpCache.ReleaseLatest.tag_name)
		StructureCache.Framework.Parent = ReplicatedStorage
		ReplicatedFirst:SetAttribute("EngineLoaderEnabled", false)

		local NewInstance = VersionController.GetCurrentInstance()

		if not CanaryStudioSettings.CanaryStudioInstaller["Enable Media Templates"] then
			for _, folderName in RequiredEngineInstances do
				if folderName ~= "Framework" and folderName ~= "ReplicatedFirst" then
					NewInstance[folderName].Media:ClearAllChildren()
				end
			end
		end

		for settingName, settingValue in CanaryStudioSettings.CanaryStudioInstaller do
			local RemoveIllegalCharacters = string.gsub(settingName, " ", "")
			NewInstance.Framework:SetAttribute(RemoveIllegalCharacters, settingValue)
		end

		FinishedFiles = 0
		
		if not TableKit.IsEmpty(HttpCache.LibrariesList) then
			for _, value in CanaryStudioSettings.CanaryStudioInstallerPackages do
				if value then
					TotalPackageFiles += 1
				end
			end
		end

		for libraryName, libraryJSON in HttpCache.LibrariesList do
			if not CanaryStudioSettings.CanaryStudioInstallerPackages[libraryName] or typeof(libraryJSON) == "Instance" then
				continue
			end

			if not PackageInstallCache:FindFirstChild(libraryName) then
				VersionController.GetDirectoryFromStructureJSON(libraryJSON, PackageInstallCache, true)
			end

			PackageInstallCache:FindFirstChild(libraryName):Clone().Parent = NewInstance[libraryJSON["$parent"] or "Replicated"].Packages
			
			FinishedFiles += 1
			VersionController.DataUpdated:Fire(FinishedFiles, TotalPackageFiles, "Installing ", "Installing latest version of packages")
		end

		FinishedFiles = 0
		TotalPackageFiles = 0

		WindowController.SetWindow("UpdateStatusWindow", false)
		WindowController.SetMessageWindow("Framework installed successfully!", Color3.fromRGB(205, 255, 151))
		
		VersionController.DataUpdated:Fire(FinishedFiles, 1, "nil", "nil")
		task.wait(UPDATE_COOLDOWN_SECONDS)
		UpdateDebounce = false
	end)
end

function VersionController.CreateNewInstanceFromName(name: string, instanceType: "Package" | "Script" | "ModuleScript", context: "Server" | "Client" | "Replicated")
	local CurrentInstance = VersionController.GetCurrentInstance()

	if not CurrentInstance then
		WindowController.SetMessageWindow("Cannot create instance; framework not installed")
		return
	end

	if instanceType == "Package" then
		instanceType = "ModuleScript"
	end

	name = string.gsub(name, "[^%a_]", "")

	local NewInstance = Instance.new(instanceType)

	if CanaryStudioSettings.CanaryStudio["Default Instance Templates"] then
		NewInstance.Source = CanaryStudioSettings.CanaryStudioInstanceTemplates[instanceType][context]
	else
		NewInstance.Source = 'print("Hello, world!")\n'
	end

	if instanceType == "ModuleScript" then
		if CanaryStudioSettings.CanaryStudio["Default Instance Templates"] then
			NewInstance.Source = string.gsub(
				NewInstance.Source,
				"Package",
				name
			)
		end

		if CanaryStudioSettings.CanaryStudio["Create Package Vendor"] then
			local InstanceFolder = Instance.new("Folder")
			local NewVendor = Instance.new("Folder")

			NewVendor.Name = "Vendor"
			NewVendor.Parent = InstanceFolder
			
			NewInstance.Name = "Init"
			NewInstance.Parent = InstanceFolder

			InstanceFolder.Name = name
			InstanceFolder.Parent = CurrentInstance[context].Packages
			
			return
		end
		
		NewInstance.Name = name
		NewInstance.Parent = CurrentInstance[context].Packages
	elseif instanceType == "Script" then
		NewInstance.Name = name
		NewInstance.RunContext = Enum.RunContext[context]

		NewInstance.Parent = CurrentInstance[context].Scripts
	end

	if CanaryStudioSettings.CanaryStudio["Select / Open New Instances"] then
		ScriptEditorService:OpenScriptDocumentAsync(NewInstance)
		SelectionService:Set({NewInstance})
	end
end

-- // Connections

-- // Actions

return VersionController