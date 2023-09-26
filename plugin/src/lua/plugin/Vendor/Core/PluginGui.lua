--!nocheck

local StudioService = game:GetService("StudioService")
local LocalizationService = game:GetService("LocalizationService")
local PlayerService = game:GetService("Players")

local Vendor = script.Parent.Parent
local Settings = require(Vendor.Settings.Settings)
local PluginGuiContents = require(Vendor.Settings.PluginGuiContents)
local WindowList = require(Vendor.Core.WindowList)
local HttpCache = require(Vendor.Core.HttpCache)
local StudioSettings = settings().Studio
local WindowController
local VersionController

local AlreadyRan = false

if not AlreadyRan then
	return function (Iris)
		AlreadyRan = true
		local PlayerName = PlayerService:GetNameFromUserIdAsync(StudioService:GetUserId())
		local FormattedPublishDate = DateTime.fromIsoDate(HttpCache.ReleaseLatest.published_at):FormatLocalTime("lll", LocalizationService.SystemLocaleId)
		local FinishedFiles = Iris.State(0)
		local TotalFiles = Iris.State(1)
		local TitleMessage = Iris.State("Updating ")
		local BelowMessage = Iris.State("Updating framework to latest version")
		
		Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)
		Iris.UpdateGlobalConfig(Iris.TemplateConfig[`color{StudioSettings.Theme.Name}`])
		StudioSettings.ThemeChanged:Connect(function()
			Iris.UpdateGlobalConfig(Iris.TemplateConfig[`color{StudioSettings.Theme.Name}`])
		end)

		Iris:Connect(function()
			WindowList.HomeWindow = Iris.Window(`Canary Studio - Home`, {isOpened = false, size = Vector2.new(355, 211)}) do
				Iris.MenuBar() do
					Iris.Menu("File") do
						if Iris.MenuItem("Release Notes").clicked() then
							WindowController.SetWindow("ReleaseNotesWindow")
						end
						
						if Iris.MenuItem("Settings").clicked() then
							WindowController.SetWindow("SettingsWindow")
						end

						if Iris.MenuItem("Exit").clicked() then
							for windowName in WindowList do
								WindowController.SetWindow(windowName, false)
							end
						end
					end Iris.End()

					Iris.Menu("Edit") do
						if Iris.MenuItem("Update Framework").clicked() then
							WindowController.SetConfirmWindow("Update Framework?\n\nUpdating will remove all current files inside of the framework itself.", VersionController.UpdateFramework)
						end

						if Iris.MenuItem({"Create Package", Enum.KeyCode.One, Enum.ModifierKey.Alt}).clicked() then
							WindowController.SetWindow("InstanceCreationWindow", true)
						end
						
						if Iris.MenuItem({"Create Script", Enum.KeyCode.Two, Enum.ModifierKey.Alt}).clicked() then
							WindowController.SetWindow("InstanceCreationWindow", true)
						end
					end Iris.End()

					Iris.Menu("View") do
						if Iris.MenuItem("Framework Installer").clicked() then
							WindowController.SetWindow("InstallerWindow")
						end

						if Iris.MenuItem("Instance Creator").clicked() then
							WindowController.SetWindow("InstanceCreationWindow")
						end

						if Iris.MenuItem("Package Manager").clicked() then
							WindowController.SetWindow("PackageManagerWindow")
						end
					end Iris.End()
				end Iris.End()

				Iris.Text(`Welcome back, {PlayerName}!`)
				Iris.Separator()
				Iris.Text({HttpCache.ExternalSettings.CanaryStudioChangelog, true})
			end Iris.End()

			WindowList.InstallerWindow = Iris.Window("Canary Studio - Installer", {isOpened = false}) do
				Iris.CollapsingHeader("Settings", {isUncollapsed = true}) do
					for settingName, defaultValue in Settings.CanaryStudioInstaller do
						if type(defaultValue) == "boolean" then
							Settings.CanaryStudioInstaller[settingName] = Iris.Checkbox(settingName, {isChecked = defaultValue}).state.isChecked:get()
						end
					end
				end Iris.End()

				Iris.CollapsingHeader("Packages") do
					for libraryName in HttpCache.LibrariesList do
						Settings.CanaryStudioInstallerPackages[libraryName] = Iris.Checkbox(libraryName).state.isChecked:get()
					end
				end Iris.End()

				Iris.SameLine() do
					if Iris.Button("Install").clicked() then
						WindowController.SetWindow("InstallerWindow", false)
						VersionController.InstallFramework()
					end

					if Iris.Button("Uninstall").clicked() then
						WindowController.SetConfirmWindow("Uninstall Framework?\n\nUninstalling will remove all traces of the framework in your game, including your own files.", VersionController.UninstallFramework)
					end
				end Iris.End()
			end Iris.End()

			WindowList.SettingsWindow = Iris.Window({"Canary Studio - Settings", [Iris.Args.Window.NoResize] = true}, {isOpened = false, size = Vector2.new(292, 238)}) do
				for settingName, currentValue in Settings.CanaryStudio do
					if type(currentValue) == "boolean" then
						Settings.CanaryStudio[settingName] = Iris.Checkbox(settingName, {isChecked = currentValue}).state.isChecked:get()
					end
				end
			end Iris.End()

			WindowList.InstanceCreationWindow = Iris.Window({"Canary Studio - Instance Creator", [Iris.Args.Window.NoResize] = true}, {isOpened = false, size = Vector2.new(285, 177)}) do
				local NameInput = Iris.InputText("Name")
				local InstanceTypeDropdown = Iris.ComboArray("Type", {index = "Script"}, {"Script", "Package"})
				local InstanceContextDropdown
				
				if InstanceTypeDropdown.state.index:get() == "Script" then
					InstanceContextDropdown = Iris.ComboArray("Context", {index = "Server"}, {"Server", "Client"})
				else
					InstanceContextDropdown = Iris.ComboArray("Context", {index = "Server"}, {"Server", "Client", "Replicated"})
				end

				if Iris.Button(`Create {InstanceTypeDropdown.state.index:get()} {NameInput.state.text:get():gsub("[^%a_]", "")}`).clicked() then
					VersionController.CreateNewInstanceFromName(NameInput.state.text:get(), InstanceTypeDropdown.state.index:get(), InstanceContextDropdown.state.index:get())
				end
			end Iris.End()

			WindowList.ReleaseNotesWindow = Iris.Window(`Release Notes for {HttpCache.ReleaseLatest.tag_name}`, {isOpened = false}) do
				Iris.Text(HttpCache.ReleaseLatest.body, true)
				Iris.Separator()
				Iris.Text(`Commit Branch: {HttpCache.ReleaseLatest.target_commitish}`)
				Iris.Text(`Published At: {FormattedPublishDate}`)
			end Iris.End()
			
			WindowList.UpdateStatusWindow = Iris.Window({`{TitleMessage:get()}({math.floor((FinishedFiles:get() / TotalFiles:get()) * 100)}%)`, [Iris.Args.Window.NoClose] = true, [Iris.Args.Window.NoResize] = true}, {isOpened = false, size = Vector2.new(334, 109)}) do
				Iris.Text(BelowMessage:get())
				Iris.Text(`{FinishedFiles:get()} of {HttpCache.ExternalSettings.Files} files`)
			end Iris.End()
			
			WindowList.PackageManagerWindow = Iris.Window("Canary Studio - Package Manager", {isOpened = false}) do
				
			end Iris.End()
			
			WindowList.ConfirmWindow = Iris.Window({"Confirm", [Iris.Args.Window.NoClose] = true, [Iris.Args.Window.NoTitleBar] = true}, {isOpened = false, size = Vector2.new(432, 122)}) do
				Iris.Text(PluginGuiContents.ConfirmWindow.MessageText, true)
				Iris.SameLine() do
					if Iris.Button("OK").clicked() then
						PluginGuiContents.ConfirmWindow.ConfirmFunction()
						WindowController.SetWindow("ConfirmWindow", false)
					end

					if Iris.Button("Cancel").clicked() then
						WindowController.SetWindow("ConfirmWindow", false)
					end
				end Iris.End()
			end Iris.End()

			WindowList.MessageWindow = Iris.Window({"Message", [Iris.Args.Window.NoClose] = true, [Iris.Args.Window.NoTitleBar] = true}, {isOpened = false, size = Vector2.new(432, 122)}) do
				Iris.Text(PluginGuiContents.MessageWindow.MessageText, true, PluginGuiContents.MessageWindow.TextColor)

				if Iris.Button("OK").clicked() then
					WindowController.SetWindow("MessageWindow", false)
					PluginGuiContents.MessageWindow.TextColor = Color3.fromRGB(255, 209, 94)
				end
			end Iris.End()
		end)

		WindowController = require(Vendor.Core.WindowController)(WindowList)
		VersionController = require(Vendor.Core.VersionController)
		
		VersionController.DataUpdated:Connect(function(files, totalfiles, title, body)
			FinishedFiles:set(files)
			TotalFiles:set(totalfiles)
			TitleMessage:set(title)
			BelowMessage:set(body)
		end)

		return WindowList
	end
end

return WindowList