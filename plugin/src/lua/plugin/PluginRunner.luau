-- // Variables

local RunService = game:GetService("RunService")

if not plugin or RunService:IsRunning() then
	return
end

local CoreGuiService = game:GetService("CoreGui")

local Vendor = script.Parent.Vendor
local Iris = require(Vendor.Iris).Init(CoreGuiService)
local TableKit = require(Vendor.TableKit)
local Fetch = require(Vendor.Fetch)
local PluginGui = require(Vendor.Core.PluginGui)(Iris)
local CanaryStudioSettings = require(Vendor.Settings)
local GitHubRequests = require(Vendor.GitHubRequests)

for scriptType, templateTable in CanaryStudioSettings.CanaryStudioInstanceTemplates do
	for context, templateURL in templateTable do
		local TemplateContents = Fetch.FetchAsync(templateURL, false)

		if not TemplateContents then
			CanaryStudioSettings.CanaryStudioInstanceTemplates[scriptType][context] = "-- could not get source"
		end

		CanaryStudioSettings.CanaryStudioInstanceTemplates[scriptType][context] = TemplateContents
	end
end

for cacheName, URL in GitHubRequests do
	Fetch.FetchAsync(URL, true, 3, cacheName)
end

local VersionController = require(Vendor.Core.VersionController)

local IsLocalPlugin = if string.find(plugin.Name, ".rbxm") or string.find(plugin.Name, ".lua") then true else false
local PluginToolbarName = if IsLocalPlugin then "Canary Studio - Local File" else "Canary Studio"
local CanaryStudioPluginToolbar = plugin:CreateToolbar(PluginToolbarName)
local CanaryStudioPluginButton = CanaryStudioPluginToolbar:CreateButton("Canary Studio", "Open Canary Studio", "rbxassetid://14374171289")

local PluginFinishedLoading = false

-- // Functions

-- // Connections

CanaryStudioPluginButton.Click:Connect(function()
	if not PluginFinishedLoading then
		warn("CanaryStudio has not finished loading yet.")
		return
	end

	PluginGui.SetWindow("HomeWindow")
end)

-- // Actions

CanaryStudioSettings.CanaryStudio = TableKit.Reconcile(
    plugin:GetSetting("CanaryStudioSettings") or CanaryStudioSettings.CanaryStudio,
    CanaryStudioSettings.CanaryStudio
) or CanaryStudioSettings.CanaryStudio

Fetch.SetHttpCacheTable(Vendor.Core.HttpCache)