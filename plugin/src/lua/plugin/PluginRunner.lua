-- // Variables

local RunService = game:GetService("RunService")

if not plugin or not RunService:IsEdit() then
	return
end

local CoreGuiService = game:GetService("CoreGui")

local Vendor = script.Parent.Vendor
local Iris = require(Vendor.Iris).Init(CoreGuiService)
local TableKit = require(Vendor.TableKit)
local Fetch = require(Vendor.Fetch)
local CanaryStudioSettings = require(Vendor.Settings.Settings)
local GitHubRequests = require(Vendor.GitHubRequests)

local IsLocalPlugin = if string.find(plugin.Name, ".rbxm") or string.find(plugin.Name, ".lua") then true else false
local PluginToolbarName = if IsLocalPlugin then "Canary Studio - Local File" else "Canary Studio"
local CanaryStudioPluginToolbar = plugin:CreateToolbar(PluginToolbarName)
local CanaryStudioPluginButton = CanaryStudioPluginToolbar:CreateButton("Canary Studio", "Open Canary Studio", "rbxassetid://14374171289")

local PluginFinishedLoading = false
local IsTesting = false

local OverrideValues = {
	ReleaseLatest = {
		published_at = "2007-01-14T20:34:22+00:00",
		body = "This is a test!",
		tag_name = "0.0.0",
		target_commitish = "main"
	},

	LibrariesList = {
		Roblox = '"TestPackage": {"$className": "ModuleScript"}',
		Is = '"TestPackage": {"$className": "ModuleScript"}',
		Cool = '"TestPackage": {"$className": "ModuleScript"}',
		["B)"] = '"TestPackage": {"$className": "ModuleScript"}',
	},

	ExternalSettings = {
		Files = 18,
		CanaryStudioChangelog = "We've made some large changes since the last update to the plugin and have fixed lots of bugs!\n\nInstalling has been revamped - The process is now a lot quicker and more performant\nRedesigned Home Page - The home page now has a menu bar and shows this changelog\nInternal code rework - It's now a lot easier to fix issues and add new features"
	},
}

local HttpCache = require(Vendor.Core.HttpCache)
Fetch.SetHttpCacheTable(Vendor.Core.HttpCache)

if IsTesting then
	for cacheName in GitHubRequests do
		HttpCache[cacheName] = OverrideValues[cacheName]
	end

	PluginFinishedLoading = true
else
	for cacheName, URL in GitHubRequests do
		local Result = Fetch.FetchAsync(URL, true, 3, cacheName)

		if not Result then
			warn("[CanaryStudio]: Could not fetch valid URL, getting local values. It is recommended to re-enter the place as most vital features will not work offline.")
			HttpCache[cacheName] = OverrideValues[cacheName]
		end
	end
end

local PluginGui = require(Vendor.Core.PluginGui)(Iris)
local WindowController = require(Vendor.Core.WindowController)(PluginGui)

CanaryStudioPluginButton.Click:Connect(function()
	if not PluginFinishedLoading then
		warn("[CanaryStudio]: Canary Studio has not finished loading yet.")
		return
	end

	WindowController.SetWindow("HomeWindow")
end)

for scriptType, templateTable in CanaryStudioSettings.CanaryStudioInstanceTemplates do
	for context, templateURL in templateTable do
		if IsTesting then
			CanaryStudioSettings.CanaryStudioInstanceTemplates[scriptType][context] = "-- this is testing!"
			continue
		end

		local TemplateContents = Fetch.FetchAsync(templateURL, false)

		if not TemplateContents then
			CanaryStudioSettings.CanaryStudioInstanceTemplates[scriptType][context] = "-- could not get source"
		end

		CanaryStudioSettings.CanaryStudioInstanceTemplates[scriptType][context] = TemplateContents
	end
end

-- // Functions

-- // Connections

-- // Actions

CanaryStudioSettings.CanaryStudio = TableKit.Reconcile(
	plugin:GetSetting("CanaryStudioPluginSettings") or CanaryStudioSettings.CanaryStudio,
	CanaryStudioSettings.CanaryStudio
) or CanaryStudioSettings.CanaryStudio

PluginFinishedLoading = true

while true do
	task.wait(10)
	plugin:SetSetting("CanaryStudioPluginSettings", CanaryStudioSettings.CanaryStudio)
end