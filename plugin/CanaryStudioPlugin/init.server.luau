-- // Variables

local RunService = game:GetService("RunService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local Selection = game:GetService("Selection")
local StudioService = game:GetService("StudioService")
local PlayerService = game:GetService("Players")
local Templates = require(script.Templates)
local NameGui = require(script.NameGui)

if not plugin or not RunService:IsEdit() then
	return
end

local IsLocalPlugin = if string.find(plugin.Name, ".rbxm") or string.find(plugin.Name, ".lua") then true else false
local PluginToolbarName = if IsLocalPlugin then "Canary Studio - Local File" else "Canary Studio"

local CanaryStudioPluginToolbar = plugin:CreateToolbar(PluginToolbarName)
local CanaryStudioPluginButton = CanaryStudioPluginToolbar:CreateButton("Canary Studio", "Open Canary Studio", "rbxassetid://14374171289")

local CreateInstanceAction = plugin:CreatePluginAction(
	"CanaryStudioCreateInstanceAction",
	"Create Instance",
	"Creates a new script / package as a child of the currently selected object",
	"rbxassetid://11295287500",
	true
)

local PLAYER_NAME = PlayerService:GetNameFromUserIdAsync(StudioService:GetUserId())

local INSTANCE_TYPE_TO_CLASS = {
	Script = "Script",
	Package = "ModuleScript",
	ModuleScript = "ModuleScript"
}

local DEFAULT_LOCATIONS = {
	Client = game:GetService("ReplicatedStorage"),
	Server = game:GetService("ServerStorage"),
	Shared = game:GetService("ReplicatedStorage")
}

local PluginMenu = plugin:CreatePluginMenu(tostring(math.random()), "CanaryStudioMenu")

local ScriptMenu = plugin:CreatePluginMenu(tostring(math.random()), "Create Script", "rbxassetid://11295287500")
local PackageMenu = plugin:CreatePluginMenu(tostring(math.random()), "Create Package", "rbxassetid://12966846573")

PackageMenu:AddNewAction("Client-Package", "Client", "rbxassetid://12974273600")
PackageMenu:AddNewAction("Server-Package", "Server", "rbxassetid://11430237002")
PackageMenu:AddNewAction("Shared-Package", "Shared", "rbxassetid://11430236009")

ScriptMenu:AddNewAction("Client-Script", "Client", "rbxassetid://12974273600")
ScriptMenu:AddNewAction("Server-Script", "Server", "rbxassetid://11430237002")

PluginMenu:AddMenu(ScriptMenu)
PluginMenu:AddMenu(PackageMenu)

-- // Functions

local function CreateInstance(name: string, instanceType: "Script" | "Package" | "ModuleScript", context: "Server" | "Client" | "Shared")
	local ObjectToParentTo = Selection:Get()[1]

	if not ObjectToParentTo then
		ObjectToParentTo = DEFAULT_LOCATIONS[context]
	end

	if ObjectToParentTo:FindFirstChild(name) and ObjectToParentTo:FindFirstChild(name):IsA(INSTANCE_TYPE_TO_CLASS[instanceType]) then
		warn(`Cannot create {string.lower(instanceType)}; {name} already exists in that dir`)
		return
	end

	if instanceType == "Package" then
		instanceType = "ModuleScript"
	end

	name = string.gsub(name, "[^%a_]", "")

	local CreatedInstance = Instance.new(instanceType)
	local CurrentDate = DateTime.now()

	local FormattedTimeHours = `{CurrentDate:FormatLocalTime("L", "en-us")} @ {CurrentDate:FormatLocalTime("LT", "en-us")}`

	ScriptEditorService:UpdateSourceAsync(CreatedInstance, function()
		local TemplateContent = Templates[instanceType]

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

		local FinishedSource = NewContextSource

		if CreatedInstance:IsA("ModuleScript") then
			local NewPackageSource = string.gsub(
				NewContextSource,
				"~PACKAGE~NAME~",
				if name == "" then "Package" else name
			)
			FinishedSource = NewPackageSource
		end

		return FinishedSource
	end)

	if CreatedInstance:IsA("Script") then
		CreatedInstance.RunContext = if context == "Client" then Enum.RunContext.Client else Enum.RunContext.Server
	end

	CreatedInstance.Name = name
	CreatedInstance.Parent = ObjectToParentTo

	Selection:Set({CreatedInstance})
	ScriptEditorService:OpenScriptDocumentAsync(CreatedInstance)
end

local function TriggerOpenMenu()
	local SelectedAction = PluginMenu:ShowAsync()

	if not SelectedAction then
		return
	end

	local ActionToComplete = string.split(SelectedAction.ActionId, "-")
	local NameBox: TextBox = NameGui.MainContainer.TextBox
	local NameToCreate: string = nil

	NameGui.Enabled = true
	NameBox:CaptureFocus()

	local Connection = NameBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			if NameBox.Text == "" then
				NameToCreate = ActionToComplete[2]
			else
				NameToCreate = NameBox.Text
			end
			NameBox.Text = ""
			NameGui.Enabled = false
		end
	end)

	repeat task.wait() until NameToCreate
	Connection:Disconnect()

	CreateInstance(NameToCreate, ActionToComplete[2] :: any, string.split(ActionToComplete[1], "_")[3] :: any)
end

-- // Connections

CreateInstanceAction.Triggered:Connect(TriggerOpenMenu)
CanaryStudioPluginButton.Click:Connect(TriggerOpenMenu)

-- // Actions

NameGui.Enabled = false
NameGui.Parent = game:GetService("CoreGui")