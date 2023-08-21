--[=[
	The parent of all classes.

	@class UIShelf
]=]
local UIShelf = { }

--[=[
	The parent of all classes.

	@class UIShelfSpacer
]=]
local UIShelfSpacer = { }
local Vendor = script.Vendor

local PlayerService = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local Player = PlayerService.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local TopbarScreenGui: ScreenGui = Vendor.Topbar:Clone()
local LeftFrame: Frame = TopbarScreenGui.TopBarFrame.LeftFrame
local RightFrame: Frame = TopbarScreenGui.TopBarFrame.RightFrame

local ChatSpacer = LeftFrame.ChatSpacer
local MoreSpacer = RightFrame.MoreSpacer

local TopbarIconBadge: Frame = Vendor.IconBadge
local TopbarIcon: Frame = Vendor.Icon
local TopbarSpacer: Frame = Vendor.Spacer

local Debugger = require(script.Parent.Parent.Debugger)
local Signal = require(script.Parent.Parent.Controllers.Vendor.SignalController)
local Types = require(script.Parent.Parent.Parent.Types)

UIShelf.__index = UIShelf
UIShelfSpacer.__index = UIShelfSpacer

TopbarScreenGui.Parent = PlayerGui
TopbarScreenGui.Archivable = false

--[=[
    @field Image string | number
    @field Name string
    @field Order number
    @field Area number

    @field SetIconEnabled (self: TopbarIcon, enabled: boolean) -> ()
    @field SetIconNotices (self: TopbarIcon, notices: number) -> ()
    @field Destroy (self: TopbarIcon) -> ()

	@interface TopbarIcon
	@within UIShelf
]=]
export type TopbarIcon = {
    Image: string | number,
    Name: string,
    Order: number,
    Area: number,

    StateChanged: Types.SignalController<string>,
    Activated: Types.SignalController<any>,
    Notified: Types.SignalController<number>,

    SetIconEnabled: (self: TopbarIcon, enabled: boolean) -> (),
    BindKeyCode: (self: TopbarIcon, keyCode: Enum.KeyCode) -> (),
    SetIconNotices: (self: TopbarIcon, notices: number) -> (),
    Destroy: (self: TopbarIcon) -> (),
}

--[=[
    @field Name string
    @field Order number
    @field Area number
    
    @field SetSpacerEnabled (self: TopbarIcon, enabled: boolean) -> ()
    @field Destroy (self: TopbarIcon) -> ()

	@interface TopbarSpacer
	@within UIShelfSpacer
]=]
export type TopbarSpacer = {
    Name: string,
    Order: number,
    Area: number,

    SetSpacerEnabled: (self: TopbarSpacer, enabled: boolean) -> (),
    Destroy: (self: TopbarSpacer) -> (),
}

--[=[
    @field CreatedIcons {TopbarIcon}
    @field CreateIcon (properties: {string | number}) -> (TopbarIcon)

	@interface UIShelf
	@within UIShelf
]=]
export type UIShelf = {
    CreatedIcons: {TopbarIcon},
    CreateIcon: (properties: {string | number}) -> (TopbarIcon),
}

if not RunService:IsClient() then
    error("Cannot run UIShelf locally")
end

while true do
    if StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat) then
        ChatSpacer.Visible = true
    else
        ChatSpacer.Visible = false
    end

    if StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) or StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) or StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu) then
        MoreSpacer.Visible = true
    else
        MoreSpacer.Visible = false
    end

    task.wait(1.5)
end

GuiService.MenuOpened:Connect(function()
    TopbarScreenGui.Enabled = false
end)

GuiService.MenuClosed:Connect(function()
    TopbarScreenGui.Enabled = true
end)

--[=[
	Creates a new topbar icon, with declared properties.

	@param properties {string | number} -- The properties to set on the icon
    @return TopbarIcon
]=]
function UIShelf.CreateIcon(properties: {string | number}): TopbarIcon
    local self = setmetatable({ }, UIShelf)
    local IconClone = TopbarIcon:Clone()

    local IconBackground = IconClone.Background
    local IconImage = IconBackground.Icon
    local IconStateOverlay = IconBackground.StateOverlay

    if type(properties[2]) == "number" then
        properties[2] = `rbxassetid://{properties[2]}`
    end

    if properties[3] < 0 then
        Debugger.Debug(error, "Order cannot be less than 0")
        return
    end

    properties[3] += 1
    if properties[4] == 2 then
        properties[3] = -properties[3]
    end

    self._Element = IconClone
    self.Name = properties[1]
    self.Image = properties[2]
    self.Order = properties[3]
    self.Area = properties[4] or 1

    self.StateChanged = Signal.NewController("StateChanged")
    self.Activated = Signal.NewController("Activated")
    self.Notified = Signal.NewController("Notified")

    self.CurrentState = "Default"
    self._KeyCodeConnection = nil

    IconBackground.MouseButton1Up:Connect(function()
        self.Activated:Fire()

        IconStateOverlay.ImageTransparency = 0.9
        IconStateOverlay.ImageColor3 = Color3.fromRGB(255, 255, 255)

        self.CurrentState = "Hovering"
        self.StateChanged:Fire(self.CurrentState)
    end)

    IconBackground.MouseButton1Down:Connect(function()
        IconStateOverlay.ImageTransparency = 0.7
        IconStateOverlay.ImageColor3 = Color3.fromRGB(0, 0, 0)

        self.CurrentState = "MouseDown"
        self.StateChanged:Fire(self.CurrentState)
    end)

    IconBackground.MouseEnter:Connect(function()
        if UserInputService.TouchEnabled then
            IconStateOverlay.ImageTransparency = 0.7
            IconStateOverlay.ImageColor3 = Color3.fromRGB(0, 0, 0)
        else
            IconStateOverlay.ImageTransparency = 0.9
            IconStateOverlay.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end

        self.CurrentState = "Hovering"
        self.StateChanged:Fire(self.CurrentState)
    end)

    IconBackground.MouseLeave:Connect(function()
        IconStateOverlay.ImageTransparency = 1
        IconStateOverlay.ImageColor3 = Color3.fromRGB(255, 255, 255)
        
        self.CurrentState = "Default"
        self.StateChanged:Fire(self.CurrentState)
    end)

    if self.Area == 1 then
        IconClone.Parent = LeftFrame
    else
        IconClone.Parent = RightFrame
    end

    IconClone:SetAttribute("Notifications", 0)

    IconClone.Name = properties[1]
    IconClone.LayoutOrder = properties[3]
    IconImage.Image = properties[2]

    return self
end

--[=[
	Creates a new topbar icon, with declared properties.

	@param enabled boolean -- Whether or not to enable the topbar
]=]
function UIShelf.SetTopBarEnabled(enabled: boolean)
    TopbarScreenGui.Enabled = enabled
end

--[=[
	Sets the status of the icon visibility.

	@param enabled boolean -- Whether or not to enable the icon
]=]
function UIShelf:SetIconEnabled(enabled: boolean)
    self._Element.Visible = enabled
end

function UIShelf:SetIconNotices(notices: number?)
    notices = notices or 1

    if notices <= 0 then
        Debugger.Debug(error, "Cannot notify 0 notifications")
        return
    end

    local TopbarIcon: Frame = self._Element
    local BadgeContainer: Frame = TopbarIcon.BadgeContainer

    if not BadgeContainer:FindFirstChild("Badge") then
        local TopbarIconBadgeClone = TopbarIconBadge:Clone()
        TopbarIconBadgeClone.Parent = BadgeContainer
    end

    local Badge: Frame = BadgeContainer.Badge
    local BadgeText: TextLabel = Badge.Inner.TextLabel

    TopbarIcon:GetAttributeChangedSignal("Notifications"):Connect(function()
        local NewValue = TopbarIcon:GetAttribute("Notifications")
        BadgeText.Text = NewValue

        if NewValue >= 1 then
            BadgeContainer.Visible = true
        elseif NewValue == 0 then
            BadgeContainer.Visible = false
        end

        if NewValue > 10 and NewValue < 99 then
            Badge.Size = UDim2.fromOffset(27, 24)
        elseif NewValue < 9 then
            Badge.Size = UDim2.fromOffset(24, 24)
        elseif NewValue > 100 then
            Badge.Size = UDim2.fromOffset(37, 24)
            BadgeText.Text = "99+"
        end
    end)

    TopbarIcon:SetAttribute("Notifications", TopbarIcon:GetAttribute("Notifications") + notices)
    self.Notified:Fire(notices + TopbarIcon:GetAttribute("Notifications"))
end

--[=[
	Binds a key code to enabling the button, pressing the specified key code will fire the activated event.

    @param keyCode Enum.KeyCode? -- The key code to listen to, if it is nil it will reset to no key code
]=]
function UIShelf:BindKeyCode(keyCode: Enum.KeyCode?)
    if (self._KeyCodeConnection and typeof(self._KeyCodeConnection) == "RBXScriptConnection") or not keyCode then
        self._KeyCodeConnection:Disconnect()

        if not keyCode then
            return
        end
    end

    self._KeyCodeConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent then
            return
        end
    
        if input.KeyCode == keyCode then
            self.Activated:Fire()
        end
    end)
end

--[=[
	Destroys the icon itself, removing it from the topbar.
]=]
function UIShelf:Destroy()
    for _, value in self do
        if typeof(value) == "RBXScriptConnection" then
            value:Disconnect()
            continue
        end

        if typeof(value) == "Instance" then
            value:Destroy()
            continue
        end

        self[value] = nil
    end

    setmetatable(self, nil)
end

--[=[
	Creates a new topbar spacer, acts a spacer to other icons.

	@param properties {string | number} -- The properties to set on the spacer
    @return TopbarSpacer
]=]
function UIShelf.CreateSpacer(properties: {string | number}): TopbarSpacer
    local self = setmetatable({ }, UIShelfSpacer)

    self.Name = properties[1]
    self.Order = properties[2]
    self.Area = properties[3]

    return self
end

function UIShelfSpacer:SetSpacerEnabled(enabled: boolean)
    
end

--[=[
	Destroys the spacer itself, removing it from the topbar.
]=]
function UIShelfSpacer:Destroy()
    
end

return UIShelf