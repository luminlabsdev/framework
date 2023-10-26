--!nocheck

-- // Variables

local VersionController = { }

local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptEditorService = game:GetService("ScriptEditorService")
local SelectionService = game:GetService("Selection")
local StudioService = game:GetService("StudioService")
local PlayerService = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

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

local PLAYER_NAME = PlayerService:GetNameFromUserIdAsync(StudioService:GetUserId())

local RequiredEngineInstances = {
	"Server",
	"Client",
	"Replicated",
	"Framework",
	"ReplicatedFirst",
}

local StructureTagOccurances = {
	["$properties"] = function(instanceFromClass: Instance, children, isPackage)
		for propertyName: string, propertyValue: string | any in children["$properties"] do
			if propertyName == "Source" and type(propertyValue) == "string" and propertyValue:find("https://") then
				local Source = Fetch.FetchAsync(propertyValue, false)

				if not Source then
					continue
				end

				if not isPackage then
					FinishedFiles += 1
					VersionController.DataUpdated:Fire(FinishedFiles, HttpCache.ExternalSettings.Files, "Updating ", "Updating framework to latest version", "files")
				end

				instanceFromClass[propertyName] = Source
			elseif type(propertyName) == "string" then
				instanceFromClass[propertyName] = propertyValue
			end
		end
	end,
	["$attributes"] = function(instanceFromClass: Instance, children)
		for attributeName: string, attributeValue: any in children["$attributes"] do
			instanceFromClass:SetAttribute(attributeName, attributeValue)
		end
	end,
	["$tags"] = function(instanceFromClass: Instance, children)
		for _, tagName: string in children["$tags"] do
			instanceFromClass:AddTag(tagName)
		end
	end,
}

local FolderToService = {
	Client = ReplicatedStorage,
	Replicated = ReplicatedStorage,
	ReplicatedFirst = ReplicatedFirst,
	Server = ServerStorage,

	EngineClient = ReplicatedStorage,
	EngineReplicated = ReplicatedStorage,
	EngineReplicatedFirst = ReplicatedFirst,
	EngineServer = ServerStorage,
}

VersionController.DataUpdated = Signal.new()
VersionController.FinishedUpdating = Signal.new()

-- // Functions

function VersionController.IsOldVersionInstalled(): boolean
	local CurrentInstance = VersionController.GetCurrentInstance()

	if CurrentInstance.Framework and not (CurrentInstance.Client or CurrentInstance.Server or CurrentInstance.ReplicatedFirst or CurrentInstance.Replicated) then
		return true
	end

	return false
end

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

		if not StructureTagOccurances[instanceName] then
			InstanceFromClass = Instance.new(children["$className"] or "Folder")
			InstanceFromClass.Name = instanceName
			InstanceFromClass.Parent = parent
		end

		for occuranceType, callback in StructureTagOccurances do
			if children[occuranceType] then
				if occuranceType == "$properties" then
					callback(InstanceFromClass, children, isPackage)
					continue
				end

				callback(InstanceFromClass, children)
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
		Server = ServerStorage:FindFirstChild("Server") or ReplicatedStorage:FindFirstChild("EngineServer"),
		Client = ReplicatedStorage:FindFirstChild("Client") or ReplicatedStorage:FindFirstChild("EngineClient"),
		Replicated = ReplicatedStorage:FindFirstChild("Replicated") or ReplicatedStorage:FindFirstChild("EngineReplicated") or ReplicatedStorage:FindFirstChild("Shared"),
		Framework = ReplicatedStorage:FindFirstChild("Framework") or ReplicatedStorage:FindFirstChild("CanaryEngineFramework"),
		ReplicatedFirst = ReplicatedFirst:FindFirstChild("ReplicatedFirst") or ReplicatedStorage:FindFirstChild("EngineReplicatedFirst")
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

function VersionController.GetCurrentTaggedInstance(ignoreNil: boolean?): {[string]: Folder}?
	ignoreNil = ignoreNil or false

	local EngineTable = {
		Server = table.unpack(CollectionService:GetTagged("__CE_Server")),
		Client = table.unpack(CollectionService:GetTagged("__CE_Client")),
		Replicated = table.unpack(CollectionService:GetTagged("__CE_Replicated")),
		Framework = table.unpack(CollectionService:GetTagged("__CE_Framework")),
		ReplicatedFirst = table.unpack(CollectionService:GetTagged("__CE_ReplicatedFirst"))
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

function VersionController.TagInstances()
	local CurrentInstance = VersionController.GetCurrentInstance()

	if not CurrentInstance then
		return
	end

	for name, folder in CurrentInstance do
		folder:AddTag(`__CE_{name}`)
	end
end

function VersionController.UninstallFramework()
	local CurrentInstance = VersionController.GetCurrentTaggedInstance(true)

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
	local CurrentInstance = VersionController.GetCurrentTaggedInstance(true)

	if not CurrentInstance then
		WindowController.SetMessageWindow("Framework is not installed; cannot update")
		return
	end

	if VersionController.IsOldVersionInstalled() then
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
		local EngineLoaderStructure = StructureCache.ReplicatedFirst.FrameworkLoader

		if CurrentInstance.Framework then
			CurrentInstance.Framework:Destroy()
			CurrentInstance.Framework = CanaryEngineStructure

			CanaryEngineStructure:SetAttribute("Version", HttpCache.ReleaseLatest.tag_name)
			CanaryEngineStructure.Parent = ReplicatedStorage
		end

		if CurrentInstance.ReplicatedFirst then	
			if CurrentInstance.ReplicatedFirst:FindFirstChild("Framework") or CurrentInstance.ReplicatedFirst:FindFirstChild("Internal") or CurrentInstance.ReplicatedFirst:FindFirstChild("FrameworkLoader") then
				local EngineItem = CurrentInstance.ReplicatedFirst:FindFirstChild("FrameworkLoader")
					or CurrentInstance.ReplicatedFirst:FindFirstChild("Internal")
					or CurrentInstance.ReplicatedFirst:FindFirstChild("Framework")

				EngineItem:Destroy()
				EngineLoaderStructure.Parent = CurrentInstance.ReplicatedFirst
			end
		end

		if ReplicatedFirst:GetAttribute("FrameworkLoaderEnabled") == nil then
			ReplicatedFirst:SetAttribute("FrameworkLoaderEnabled", false)
		end

		WindowController.SetWindow("UpdateStatusWindow", false)
		WindowController.SetMessageWindow("Framework updated successfully!", Color3.fromRGB(205, 255, 151))

		task.wait(UPDATE_COOLDOWN_SECONDS)
		UpdateDebounce = false
		FinishedFiles = 0
		VersionController.DataUpdated:Fire(FinishedFiles, 1, "nil", "nil", "nil")
	end)
end

function VersionController.InstallPackagesFromList(list: {[string]: boolean})
	task.defer(function()
		local CurrentInstance = VersionController.GetCurrentTaggedInstance()
		FinishedFiles = 0

		for _, value in list do
			if value then
				TotalPackageFiles += 1
			end
		end

		if TotalPackageFiles == 0 then
			WindowController.SetWindow("UpdateStatusWindow", false)
			VersionController.DataUpdated:Fire(FinishedFiles, 1, "nil", "nil", "nil")
			return
		end

		VersionController.DataUpdated:Fire(FinishedFiles, TotalPackageFiles, "Installing ", "Installing latest version of packages", "packages")
		WindowController.SetWindow("UpdateStatusWindow", true)

		for libraryName, libraryJSON in HttpCache.LibrariesList do
			if not list[libraryName] or typeof(libraryJSON) == "Instance" then
				continue
			end

			if not PackageInstallCache:FindFirstChild(libraryName) then
				VersionController.GetDirectoryFromStructureJSON(libraryJSON, PackageInstallCache, true)
			end

			PackageInstallCache:FindFirstChild(libraryName):Clone().Parent = CurrentInstance[libraryJSON["$parent"] or "Replicated"].Packages

			FinishedFiles += 1
			VersionController.DataUpdated:Fire(FinishedFiles, TotalPackageFiles, "Installing ", "Installing latest version of packages", "packages")
		end

		FinishedFiles = 0
		TotalPackageFiles = 0

		WindowController.SetWindow("UpdateStatusWindow", false)
		WindowController.SetMessageWindow("Packages installed successfully!", Color3.fromRGB(205, 255, 151))

		VersionController.DataUpdated:Fire(FinishedFiles, 1, "nil", "nil", "nil")
		VersionController.FinishedUpdating:Fire()
	end)
end

function VersionController.InstallFramework()
	if VersionController.GetCurrentTaggedInstance(true) then
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
		ReplicatedFirst:SetAttribute("FrameworkLoaderEnabled", false)

		local NewInstance = VersionController.GetCurrentTaggedInstance()

		if not CanaryStudioSettings.CanaryStudioInstaller["Enable Asset Templates"] then
			for _, folderName in RequiredEngineInstances do
				if folderName ~= "Framework" and folderName ~= "ReplicatedFirst" then
					NewInstance[folderName].Assets:ClearAllChildren()
				end
			end
		end

		for settingName, settingValue in CanaryStudioSettings.CanaryStudioInstaller do
			local RemoveIllegalCharacters = string.gsub(settingName, " ", "")
			NewInstance.Framework:SetAttribute(RemoveIllegalCharacters, settingValue)
		end

		VersionController.InstallPackagesFromList(CanaryStudioSettings.CanaryStudioInstallerPackages)
		WindowController.SetMessageWindow("Framework installed successfully!", Color3.fromRGB(205, 255, 151))

		VersionController.FinishedUpdating:Once(function()
			WindowController.SetWindow("UpdateStatusWindow", false)
		end)

		task.wait(UPDATE_COOLDOWN_SECONDS)
		UpdateDebounce = false
	end)
end

function VersionController.CreateNewInstanceFromName(name: string, instanceType: "Package" | "Script" | "ModuleScript", context: "Server" | "Client" | "Replicated" | "ReplicatedFirst")
	local CurrentInstance = VersionController.GetCurrentTaggedInstance()

	if not CurrentInstance then
		WindowController.SetMessageWindow("Cannot create instance; framework not installed")
		return
	end

	if CurrentInstance[context][`{instanceType}s`]:FindFirstChild(name) then
		WindowController.SetMessageWindow(`Cannot create {string.lower(instanceType)}; {name} already exists in that dir`)
		return
	end

	if instanceType == "Package" then
		instanceType = "ModuleScript"
	end

	name = string.gsub(name, "[^%a_]", "")

	local NewInstance = Instance.new(instanceType)
	local CurrentDate = DateTime.now()

	local FormattedTimeHours = `{CurrentDate:FormatLocalTime("L", "en-us")} @ {CurrentDate:FormatLocalTime("LT", "en-us")}`

	task.defer(function()
		if CanaryStudioSettings.CanaryStudio["Default Instance Templates"] then
			ScriptEditorService:UpdateSourceAsync(NewInstance, function()
				local TemplateContent = CanaryStudioSettings.CanaryStudioInstanceTemplates[instanceType]

				if context == "ReplicatedFirst" then
					TemplateContent = CanaryStudioSettings.CanaryStudioInstanceTemplates.SpecialScript
				end

				local NewAuthorSource = string.gsub(
					TemplateContent,
					"~AUTHOR~",
					`--[[\n\t  by {PLAYER_NAME}\n\t  {FormattedTimeHours}\n--]]`
				)

				local NewContextSource = string.gsub(
					NewAuthorSource,
					"~FRAMEWORK~TYPE~",
					context
				)

				return NewContextSource
			end)
		else
			ScriptEditorService:UpdateSourceAsync(NewInstance, function()
				return 'print("Hello, world!")\n'
			end)
		end
	end)

	if instanceType == "ModuleScript" then
		if CanaryStudioSettings.CanaryStudio["Default Instance Templates"] then
			task.defer(function()
				ScriptEditorService:UpdateSourceAsync(NewInstance, function(scriptContent)
					local NewPackageNameSource = string.gsub(
						scriptContent,
						"~PACKAGE~NAME~",
						if name == "" then "Package" else name
					)
					
					local NewVendorSource = string.gsub(
						NewPackageNameSource,
						"~VENDOR~",
						if CanaryStudioSettings.CanaryStudio["Create Package Vendor"] then "local Vendor = script.Parent.Vendor" else ""
					)

					return NewVendorSource
				end)
			end)
		end

		if CanaryStudioSettings.CanaryStudio["Create Package Vendor"] then
			local InstanceFolder = Instance.new("Folder")
			local NewVendor = Instance.new("Folder")

			if CanaryStudioSettings.CanaryStudio["Instance Author Attributes"] then
				InstanceFolder:SetAttribute("Author", PLAYER_NAME)
				InstanceFolder:SetAttribute("Created", FormattedTimeHours)
			end

			NewVendor.Name = "Vendor"
			NewVendor.Parent = InstanceFolder

			NewInstance.Name = "Init"
			NewInstance.Parent = InstanceFolder

			InstanceFolder.Name = name
			InstanceFolder.Parent = CurrentInstance[context].Packages

			if CanaryStudioSettings.CanaryStudio["Select / Open New Instances"] then
				ScriptEditorService:OpenScriptDocumentAsync(NewInstance)
				SelectionService:Set({NewInstance})
			end

			return
		end

		NewInstance.Name = name
		NewInstance.Parent = CurrentInstance[context].Packages
	elseif instanceType == "Script" then
		if CanaryStudioSettings.CanaryStudio["Instance Author Attributes"] then
			NewInstance:SetAttribute("Author", PLAYER_NAME)
			NewInstance:SetAttribute("Created", FormattedTimeHours)
		end

		NewInstance.Name = name
		
		if context == "ReplicatedFirst" then
			NewInstance.RunContext = Enum.RunContext.Client
		else
			NewInstance.RunContext = Enum.RunContext[context]
		end

		NewInstance.Parent = CurrentInstance[context].Scripts
	end

	if CanaryStudioSettings.CanaryStudio["Select / Open New Instances"] then
		ScriptEditorService:OpenScriptDocumentAsync(NewInstance)
		SelectionService:Set({NewInstance})
	end
end

-- // Connections

-- // Actions

VersionController.TagInstances()

return VersionController