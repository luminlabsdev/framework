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
local CanaryStudioSettings = require(Vendor.Settings.Settings)
local GitHubRequests = require(Vendor.GitHubRequests)

local IsLocalPlugin = if string.find(plugin.Name, ".rbxm") or string.find(plugin.Name, ".lua") then true else false
local PluginToolbarName = if IsLocalPlugin then "Canary Studio - Local File" else "Canary Studio"
local CanaryStudioPluginToolbar = plugin:CreateToolbar(PluginToolbarName)
local CanaryStudioPluginButton = CanaryStudioPluginToolbar:CreateButton("Canary Studio", "Open Canary Studio", "rbxassetid://14374171289")

local PluginFinishedLoading = false
local IsTesting = true

Fetch.SetHttpCacheTable(Vendor.Core.HttpCache)

if IsTesting then
	local HttpCache = require(Vendor.Core.HttpCache)
	PluginFinishedLoading = true
	
	for cacheName in GitHubRequests do
		if cacheName == "ReleaseLatest" then
			HttpCache[cacheName] = {
				published_at = "2007-01-14T20:34:22+00:00",
				body = "This is a test!",
				tag_name = "0.0.0",
				target_commitish = "main"
			}
		elseif cacheName == "LibrariesList" then
			HttpCache[cacheName] = {
				Roblox = true,
				Is = true,
				Cool = true,
				["B)"] = true,
			}
		elseif cacheName == "ExternalSettings" then
			HttpCache[cacheName] = {
				Files = 11
			}
		end
	end
else
	for cacheName, URL in GitHubRequests do
		Fetch.FetchAsync(URL, true, 3, cacheName)
	end
end

local PluginGui = require(Vendor.Core.PluginGui)(Iris)
local WindowController = require(Vendor.Core.WindowController)(PluginGui)

CanaryStudioPluginButton.Click:Connect(function()
	if not PluginFinishedLoading then
		warn("CanaryStudio has not finished loading yet.")
		return
	end

	WindowController.SetWindow("HomeWindow")
end)

if IsTesting then
	for scriptType, templateTable in CanaryStudioSettings.CanaryStudioInstanceTemplates do
		for context, templateURL in templateTable do
			CanaryStudioSettings.CanaryStudioInstanceTemplates[scriptType][context] = "-- this is testing!"
		end
	end
else
	for scriptType, templateTable in CanaryStudioSettings.CanaryStudioInstanceTemplates do
		for context, templateURL in templateTable do
			local TemplateContents = Fetch.FetchAsync(templateURL, false)

			if not TemplateContents then
				CanaryStudioSettings.CanaryStudioInstanceTemplates[scriptType][context] = "-- could not get source"
			end

			CanaryStudioSettings.CanaryStudioInstanceTemplates[scriptType][context] = TemplateContents
		end
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