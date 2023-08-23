--[=[
	The parent of all classes.

	@class UIShelf
]=]
local UIShelf = { }

--[=[
	The parent of all classes.

	@class TopBarIconObject
]=]
local TopBarIconObject = { }

--[=[
	The parent of all classes.

	@class TopBarSpacerObject
]=]
local TopBarSpacerObject = { }

TopBarSpacerObject.__index = TopBarSpacerObject
TopBarIconObject.__index = TopBarIconObject
UIShelf.__index = UIShelf

UIShelf.CreatedIcons = { }

local Vendor = script.Vendor

local PlayerService = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local Player = PlayerService.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local TopbarScreenGui = Vendor.Topbar:Clone()
local LeftFrame = TopbarScreenGui.TopBarFrame.LeftFrame
local RightFrame = TopbarScreenGui.TopBarFrame.RightFrame

local ChatSpacer = LeftFrame.ChatSpacer
local MoreSpacer = RightFrame.MoreSpacer

local TopbarIconBadge: Frame = Vendor.Badge
local TopbarIcon: Frame = Vendor.Icon
local TopbarSpacer: Frame = Vendor.Spacer

local Debugger = require(script.Parent.Parent.Debugger)
local Signal = require(script.Parent.Parent.Controllers.Vendor.SignalController)
local Types = require(script.Parent.Parent.Parent.Types)

local NOTICE_UI_PADDING = 14

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

	@interface TopBarIcon
	@within UIShelf
]=]
export type TopBarIcon = {
	Image: string | number,
	Name: string,
	Order: number,
	Area: number,

	StateChanged: Types.SignalController<string>,
	Activated: Types.SignalController<Enum.UserInputType>,
	NoticeAdded: Types.SignalController<number>,

	Notices: number,
	NoticeCap: string,
	CurrentState: string,

	SetImageSize: (self: TopBarIcon, imageSize: Vector2) -> (),
	SetIconEnabled: (self: TopBarIcon, enabled: boolean) -> (),
	BindKeyCodes: (self: TopBarIcon, keyCodes: {Enum.KeyCode}?) -> (),
	SetIconNotices: (self: TopBarIcon, notices: number?, noticeCap: number?) -> (),
	Destroy: (self: TopBarIcon) -> (),
}

--[=[
	@field Name string
	@field Order number
	@field Area number
    
	@field SetSpacerEnabled (self: TopbarIcon, enabled: boolean) -> ()
	@field Destroy (self: TopbarIcon) -> ()

	@interface TopBarSpacer
	@within UIShelfSpacer
]=]
export type TopBarSpacer = {
	Name: string,
	Order: number,
	Area: number,

	SetSpacerEnabled: (self: TopBarSpacer, enabled: boolean) -> (),
	Destroy: (self: TopBarSpacer) -> (),
}

--[=[
	@field CreatedIcons {TopbarIcon}
	@field CreateIcon (properties: {string | number}) -> (TopbarIcon)

	@interface UIShelf
	@within UIShelf
]=]
export type UIShelf = {
	CreatedIcons: {TopBarIcon},
	CreateIcon: (properties: {string | number}) -> (TopBarIcon),
	CreateSpacer: (properties: {string | number}) -> (TopBarSpacer),
	SetTopBarEnabled: (enabled: boolean) -> ()
}

if not RunService:IsClient() then
	error("Can only run UIShelf locally")
end

task.defer(function()
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
end)

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
function UIShelf.CreateIcon(properties: {string | number}): TopbarIcon?
	local self = setmetatable({ }, TopBarIconObject)
	local IconClone = TopbarIcon:Clone()

	local IconBackground = IconClone.Background
	local IconImage = IconBackground.Icon
	local IconStateOverlay = IconBackground.StateOverlay

	if type(properties[2]) == "number" then
		properties[2] = `rbxassetid://{properties[2]}`
	end

	if properties[3] <= 0 then
		Debugger.Debug(error, "Order cannot be less than 0")
		return nil
	end

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
	self.NoticeAdded = Signal.NewController("Notified")

	self.Notices = 0
	self.NoticeCap = "99+"
	self.CurrentState = "Default"

	self._KeyCodeConnections = nil
	self._NoticeConnection = nil

	IconBackground.MouseButton1Up:Connect(function()
		if UserInputService.MouseEnabled then
			self.Activated:Fire(Enum.UserInputType.MouseButton1)
		elseif UserInputService.TouchEnabled then
			self.Activated:Fire(Enum.UserInputType.Touch)
		end

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

	IconBackground.SelectionGained:Connect(function()
		self.CurrentState = "Hovering"
		self.StateChanged:Fire(self.CurrentState)
	end)

	if self.Area == 1 then
		IconClone.Parent = LeftFrame
	elseif self.Area == 2 then
		IconClone.Parent = RightFrame
	end

	IconClone:SetAttribute("Notices", 0)

	IconClone.Name = properties[1]
	IconClone.LayoutOrder = properties[3]
	IconImage.Image = properties[2]
	
	table.insert(UIShelf.CreatedIcons, self)

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
function TopBarIconObject:SetIconEnabled(enabled: boolean)
	self._Element.Visible = enabled
end

--[=[
	Adds notices to the parent topbar icon.

	@param notices number? -- The amount of notices to add, leaving this nil will add a single notice
	@param noticeCap number? -- When to display a + sign after a set amount of notices, defaults to 99
]=]
function TopBarIconObject:SetIconNotices(notices: number?, noticeCap: number?)
	notices = notices or 1
	noticeCap = noticeCap or 99

	if notices <= 0 then
		Debugger.Debug(error, "Cannot notify 0 notifications")
		return
	end

	local TopbarIcon = self._Element
	local BadgeContainer = TopbarIcon.BadgeContainer

	if not BadgeContainer:FindFirstChild("Badge") then
		local TopbarIconBadgeClone = TopbarIconBadge:Clone()
		TopbarIconBadgeClone.Parent = BadgeContainer
	end

	local Badge = BadgeContainer.Badge
	local BadgeText = Badge.Inner.TextLabel
	
	if noticeCap then
		self.NoticeCap = `{noticeCap}+`
	end

	if not self._NoticeConnection then
		self._NoticeConnection = TopbarIcon:GetAttributeChangedSignal("Notices"):Connect(function()
			local NewValue = TopbarIcon:GetAttribute("Notices")
			BadgeText.Text = NewValue

			if NewValue >= 1 then
				BadgeContainer.Visible = true
			elseif NewValue == 0 then
				BadgeContainer.Visible = false
			end

			if NewValue > noticeCap then
				BadgeText.Text = self.NoticeCap
			end

			if NewValue <= 9 then
				Badge.Size = UDim2.fromOffset(24, 24)
				return
			end

			Badge.Size = UDim2.fromOffset(BadgeText.TextBounds.X + NOTICE_UI_PADDING, 24)
		end)
	end

	TopbarIcon:SetAttribute("Notices", TopbarIcon:GetAttribute("Notices") + notices)

	self.NoticeAdded:Fire(TopbarIcon:GetAttribute("Notices"))
	self.Notices += notices
end

--[=[
	Binds multiple key codes to activate the icons `Activated` event.

	@param keyCodes {Enum.KeyCode}? -- The key codes to listen to, if it is nil it will reset to no key codes
]=]
function TopBarIconObject:BindKeyCodes(keyCodes: {Enum.KeyCode}?)
	self._KeyCodeConnections = { }

	if self._KeyCodeConnections[1] and not keyCodes then
		self._KeyCodeConnections:Disconnect()

		if not keyCodes then
			return
		end
	end

	for _, keyCode in keyCodes :: {Enum.KeyCode} do
		table.insert(self._KeyCodeConnections, UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
			if gameProcessedEvent then
				return
			end

			if input.KeyCode == keyCode then
				self.Activated:Fire(input.UserInputType)
			end
		end))
	end
end

--[=[
	Sets the image size of the icon, default is filled.
	
	@param imageSize Vector2 -- The size to set the image to
]=]
function TopBarIconObject:SetImageSize(imageSize: Vector2)
	local TopBarIcon = self._Element
	local TopBarIconImage = TopBarIcon.Background.Icon

	TopBarIconImage.Size = UDim2.fromOffset(imageSize.X, imageSize.Y)
end

--[=[
	Destroys the icon itself, removing it from the topbar.
]=]
function TopBarIconObject:Destroy()
	for _, connection in self._KeyCodeConnections do
		connection:Disconnect()
	end

	if self._NoticeConnection then
		self._NoticeConnection:Disconnect()
	end

	for _, value in self do
		if typeof(value) == "Instance" then
			value:Destroy()
			continue
		end

		self[value] = nil
	end
	
	table.remove(UIShelf.CreatedIcons, table.find(UIShelf.CreatedIcons, self))
	setmetatable(self, nil)
end

--[=[
	Creates a new topbar spacer, acts a spacer to other icons.

	@param properties {string | number} -- The properties to set on the spacer
	@return TopbarSpacer
]=]
function UIShelf.CreateSpacer(properties: {string | number}): TopbarSpacer?
	local self = setmetatable({ }, TopBarSpacerObject)
	local SpacerClone = TopbarSpacer:Clone()

	if properties[2] <= 0 then
		Debugger.Debug(error, "Order cannot be less than 0")
		return nil
	end

	if properties[3] == 2 then
		properties[2] = -properties[2]
	end

	self._Element = SpacerClone
	self.Name = properties[1]
	self.Order = properties[2]
	self.Area = properties[3]

	if self.Area == 1 then
		SpacerClone.Parent = LeftFrame
	elseif self.Area == 2 then
		SpacerClone.Parent = RightFrame
	end

	SpacerClone.Name = properties[1]
	SpacerClone.LayoutOrder = properties[3]

	return self
end

--[=[
	Sets whether or not the spacer should be enabled.

	@param enabled boolean -- Whether or not the spacer should be enabled
]=]
function TopBarSpacerObject:SetSpacerEnabled(enabled: boolean)
	local TopBarSpacer = self._Element

	TopBarSpacer.Visible = enabled
end

--[=[
	Destroys the spacer itself, removing it from the topbar.
]=]
function TopBarSpacerObject:Destroy()
	for _, value in self do
		if typeof(value) == "Instance" then
			value:Destroy()
			continue
		end

		self[value] = nil
	end

	setmetatable(self, nil)
end

return UIShelf :: UIShelf