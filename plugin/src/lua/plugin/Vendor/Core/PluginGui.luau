local WindowList = { }

local StudioService = game:GetService("StudioService")
local LocalizationService = game:GetService("LocalizationService")
local PlayerService = game:GetService("Players")

local Vendor = script.Parent.Parent
local VersionController = require(Vendor.Core.VersionController)
local Settings = require(Vendor.Settings.Settings)
local PluginGuiContents = require(Vendor.Settings.PluginGuiContents)
local HttpCache = require(Vendor.Core.HttpCache)
local StudioSettings = settings().Studio
local WindowController

local AlreadyRan = false

if not AlreadyRan then
    return function (Iris)
        AlreadyRan = true
        local PlayerName = PlayerService:GetNameFromUserIdAsync(StudioService:GetUserId())
        local FormattedPublishDate = DateTime.fromIsoDate(HttpCache.ReleaseLatest.published_at):FormatLocalTime("lll", LocalizationService.SystemLocaleId)
    
        Iris.UpdateGlobalConfig(Iris.TemplateConfig[`color{StudioSettings.Theme.Name}`])
        StudioSettings.ThemeChanged:Connect(function()
            Iris.UpdateGlobalConfig(Iris.TemplateConfig[`color{StudioSettings.Theme.Name}`])
        end)
    
        Iris:Connect(function()
            WindowList.HomeWindow = Iris.Window(`Canary Studio - Home`, {isOpened = false}) do
                Iris.MenuBar() do
                    Iris.Menu("File") do
                        if Iris.MenuItem("Update Framework").clicked() then
                            VersionController.UpdateFramework()
                        end
        
                        if Iris.MenuItem("Settings").clicked() then
                            WindowController.SetWindow("SettingsWindow")
                        end
        
                        if Iris.MenuItem("Exit").clicked() then
                            WindowController.SetWindow("HomeWindow", false)
                        end
                    end Iris.End()
        
                    Iris.Menu("Edit") do
                        Iris.MenuItem({"Create Package", Enum.KeyCode.One, Enum.ModifierKey.Alt})
                        Iris.MenuItem({"Create Script", Enum.KeyCode.Two, Enum.ModifierKey.Alt})
                    end Iris.End()
        
                    Iris.Menu("View") do
                        if Iris.MenuItem("Install Framework").clicked() then
                            WindowController.SetWindow("InstallerWindow")
                        end
        
                        if Iris.MenuItem("Uninstall Framework").clicked() then
                            VersionController.UninstallFramework()
                        end

                        if Iris.MenuItem("Instance Creator").clicked() then
                            WindowController.SetWindow("InstanceCreationWindow")
                        end
        
                        if Iris.MenuItem("Release Notes").clicked() then
                            WindowController.SetWindow("ReleaseNotesWindow")
                        end

                        Iris.MenuItem("Package Manager")
                    end Iris.End()
                end Iris.End()
        
                Iris.Text(`Welcome back, {PlayerName}!`)
                Iris.Separator()
                Iris.Text(HttpCache.ReleaseNotes)
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
                    for libraryName in HttpCache.Libraries do
                        Settings.CanaryStudioInstallerPackages[libraryName] = Iris.Checkbox(libraryName).state.isChecked:get()
                    end
                end Iris.End()
        
                if Iris.Button("Install").clicked() then
                    WindowController.SetWindow("InstallerWindow", false)
                    VersionController.InstallFramework()
                end
            end Iris.End()
        
            WindowList.SettingsWindow = Iris.Window("Canary Studio - Settings", {isOpened = false}) do
                for settingName, currentValue in Settings.CanaryStudio do
                    if type(currentValue) == "boolean" then
                        Settings.CanaryStudio[settingName] = Iris.Checkbox(settingName, {isChecked = currentValue}).state.isChecked:get()
                    end
                end
            end Iris.End()

            WindowList.InstanceCreationWindow = Iris.Window("Canary Studio - Instance Creator", {isOpened = false}) do
                local IsScript = Iris.State(false)
                local Context = Iris.State("Server")

                local ScriptCheckbox
                local PackageCheckbox

                local NameInput = Iris.InputText(nil, "package or script name...")

                Iris.SameLine() do
                    ScriptCheckbox = Iris.Checkbox("Script")
                    PackageCheckbox = Iris.Checkbox("Package")

                    if ScriptCheckbox.state.isChecked then
                        IsScript:set(true)
                        PackageCheckbox.state.isChecked:set(false)
                    end

                    if PackageCheckbox.state.isChecked then
                        IsScript:set(false)
                        ScriptCheckbox.state.isChecked:set(false)
                    end
                end Iris.End()

                Iris.SameLine() do
                    if Iris.Checkbox("Server", {isChecked = true}) then
                        Context:set("Server")
                    end

                    if Iris.Checkbox("Client", {isChecked = false}) then
                        Context:set("Client")
                    end

                    if not IsScript:get() then
                        if Iris.Checkbox("Replicated", {isChecked = false}) then
                            Context:set("Replicated")
                        end
                    end
                end Iris.End()

                if Iris.Button(`Create {if IsScript:get() then "Script" else "Package"}`).clicked() then
                    VersionController.CreateNewInstanceFromName(NameInput.state.text, if IsScript:get() then "Script" else "ModuleScript", Context:get())
                end
            end Iris.End()

            WindowList.ReleaseNotesWindow = Iris.Window(`Release Notes for {HttpCache.ReleaseLatest.tag_name}`, {isOpened = false}) do
                Iris.Text(HttpCache.ReleaseLatest.body, true)
                Iris.Separator()
                Iris.Text(`Commit Branch: {HttpCache.ReleaseLatest.target_commitish}`)
                Iris.Text(`Published At: {FormattedPublishDate}`)
            end Iris.End()
        
            WindowList.ConfirmWindow = Iris.Window("Confirm", {isOpened = false}) do
                Iris.Text(PluginGuiContents.Confirm.MessageText, true)
                Iris.SameLine() do
                    if Iris.Button("Continue").clicked() then
                        PluginGuiContents.Confirm.ConfirmFunction()
                        WindowController.SetWindow("ConfirmWindow", false)
                    end
        
                    if Iris.Button("Cancel").clicked() then
                        WindowController.SetWindow("ConfirmWindow", false)
                    end
                end Iris.End()
            end Iris.End()
        
            WindowList.MessageWindow = Iris.Window("Message", {isOpened = false}) do
                Iris.Text(PluginGuiContents.Message.MessageText, true, PluginGuiContents.Message.TextColor)
        
                if Iris.Button("OK").clicked() then
                    WindowController.SetWindow("MessageWindow", false)
                    PluginGuiContents.Message.TextColor = Color3.fromRGB(255, 209, 94)
                end
            end Iris.End()
        end)

        WindowController = require(Vendor.Core.WindowController)(WindowList)
    
        return WindowList
    end
end

return WindowList