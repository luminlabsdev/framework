--[=[
	The parent of all classes.

	@class UIShelf
]=]
local UIShelf = { }

--[=[
	A table of every topbar icon created.

	@prop CreatedIcons {TopBarIconObject}
	@within UIShelf
]=]

--[=[
	Whether or not voice chat is enabled in your game, this must be toggled accordingly or your icons will display incorrectly.

	@prop VoiceChatEnabled boolean
	@within UIShelf
]=]

--[=[
	Whether or not the topbar is enabled for UIShelf.

	@prop TopBarEnabled boolean
	@within UIShelf
]=]

--[=[
	The parent of all classes.

	@class TopBarIconObject
]=]
local TopBarIconObject = { }

--[=[
	The image to display on the icon.

	@prop Image string | number
	@within TopBarIconObject
]=]

--[=[
	The name of the icon.

	@prop Name string
	@within TopBarIconObject
]=]

--[=[
	The layout order of the icon.

	@prop Order number
	@within TopBarIconObject
]=]

--[=[
	The area of the icon. `1` is Left and `2` is Right.

	@prop Area number
	@within TopBarIconObject
]=]

--[=[
	Fires whenever the state of the icon changes. For example: Hovering -> Default

	@tag Event

	@prop StateChanged PublicSignalController<string>
	@within TopBarIconObject
]=]

--[=[
	Fires when the icon is activated, by any supported input type. Also passes in the user input type enum.

	@tag Event

	@prop Activated PublicSignalController<Enum.UserInputType>
	@within TopBarIconObject
]=]

--[=[
	Fires whenever a notice is added to the icon.

	@tag Event

	@prop NoticeAdded PublicSignalController<number>
	@within TopBarIconObject
]=]

--[=[
	The amount of notices the icon actually has.

	@prop Notices number
	@within TopBarIconObject
]=]

--[=[
	The notice cap string, an example of this is "99+" for the default.

	@prop NoticeCap string
	@within TopBarIconObject
]=]

--[=[
	Describes the current state of the icon, works like how [TopBarIconObject.StateChanged] does.

	@prop CurrentState string
	@within TopBarIconObject
]=]

--[=[
	The parent of all classes.

	@class TopBarSpacerObject
]=]
local TopBarSpacerObject = { }

--[=[
	The name of the spacer.

	@prop Name string
	@within TopBarSpacerObject
]=]

--[=[
	The layout order of the spacer.

	@prop Order number
	@within TopBarSpacerObject
]=]

--[=[
	The area of the spacer. `1` is Left and `2` is Right.

	@prop Area number
	@within TopBarSpacerObject
]=]

-- // Variables

TopBarSpacerObject.__index = TopBarSpacerObject
TopBarIconObject.__index = TopBarIconObject
UIShelf.__index = UIShelf

UIShelf.CreatedIcons = { }
UIShelf.VoiceChatEnabled = true
UIShelf.TopBarEnabled = true

local Vendor = script.Vendor

local PlayerService = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local VoiceChatService = game:GetService("VoiceChatService")
local CollectionService = game:GetService("CollectionService")

local Player = PlayerService.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local TopbarScreenGui = Vendor.TopBarApp:Clone()
local TooltipScreenGui = Vendor.TooltipLayer:Clone()
local LeftFrame = TopbarScreenGui.TopBarFrame.LeftFrame
local RightFrame = TopbarScreenGui.TopBarFrame.RightFrame

local TopbarIconBadge: Frame = Vendor.Badge
local TopbarIcon: Frame = Vendor.Icon
local TopbarSpacer: Frame = Vendor.Spacer
local IconTooltip: CanvasGroup = Vendor.Tooltip
local ContextMenuObject: ImageButton = Vendor.ContentMenuObject

local Debugger = require(script.Parent.Parent.Debugger)
local Signal = require(script.Parent.Parent.Controllers.Vendor.SignalController)
local Types = require(script.Parent.Parent.Parent.Types)

local DEFAULT_TRANSPARENCYOUT_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local DEFAULT_TRANSPARENCYIN_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local NOTICE_UI_PADDING = 14
local TOPBAR_FRAMES = {
	LeftFrame,
	RightFrame,
}

local CONTEXTMENU_POSITIONS = {
	[1] = 5.46,
	[2] = 1
}

local STATEOVERLAY_PROPERTIES = {
	Default = {
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	},
	Hovering = {
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	},
	MouseDown = {
		BackgroundTransparency = 0.7,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	},
	MouseUpHovering = {
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	},
}

local STATEOVERLAY_CONTEXTMENU_PROPERTIES = {
	Default = {
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	},
	Hovering = {
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	},
	MouseDown = {
		BackgroundTransparency = 0.7,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	},
}

local EVENTS_FOR_CONNECTION_ICON = {
	MouseButton1Up = "MouseUpHovering",
	MouseButton1Down = "MouseDown",
	MouseEnter = "Hovering",
	MouseLeave = "Default",
	SelectionGained = "Hovering",
	SelectionLost = "Default"
}

local EVENTS_FOR_CONNECTION_MENU = {
	MouseButton1Up = "Hovering",
	MouseButton1Down = "MouseDown",
	MouseEnter = "Hovering",
	MouseLeave = "Default",
}

TopbarScreenGui.Parent = PlayerGui
TopbarScreenGui.Archivable = false

TooltipScreenGui.Parent = PlayerGui
TooltipScreenGui.Archivable = false

-- // Types

export type TopBarIcon = {
	Image: string | number,
	Name: string,
	Order: number,
	Area: number,

	StateChanged: Types.PublicSignalController<string>,
	Activated: Types.PublicSignalController<Enum.UserInputType>,
	NoticeAdded: Types.PublicSignalController<number>,
	NoticeRemoved: Types.PublicSignalController<nil>,

	Notices: number,
	NoticeCap: string,
	NoticeCapNum: number,
	CurrentState: string,

	SetImageSize: (self: TopBarIcon, imageSize: Vector2) -> (),
	SetImageRect: (self: TopBarIcon, rectSize: Rect, rectOffset: Rect) -> (),
	SetIconEnabled: (self: TopBarIcon, enabled: boolean) -> (),
	SetTooltip: (self: TopBarIcon, text: string?) -> (),
	UpdateStateOverlay: (self: TopBarIcon, newState: "Default" | "Hovering" | "MouseDown" | "MouseUpHovering") -> (),
	SetTooltipEnabled: (self: TopBarIcon, enabled: boolean) -> (),
	CreateContextMenu: (self: TopBarIcon, contextMenuContents: {{string | number}}) -> (),
	BindKeyCodes: (self: TopBarIcon, keyCodes: {Enum.KeyCode}?) -> (),
	BindGuiObject: (self: TopBarIcon, guiObject: GuiObject) -> (),
	AddIconNotices: (self: TopBarIcon, notices: number?, noticeCap: number?) -> (),
	RemoveIconNotices: (self: TopBarIcon, notices: number?) -> (),
	Destroy: (self: TopBarIcon) -> (),
}

export type TopBarSpacer = {
	Name: string,
	Order: number,
	Area: number,

	SetSpacerEnabled: (self: TopBarSpacer, enabled: boolean) -> (),
	SetSpacerSize: (self: TopBarSpacer, size: number) -> (),
	Destroy: (self: TopBarSpacer) -> (),
}

type UIShelf = {
	CreatedIcons: {TopBarIcon},
	VoiceChatEnabled: boolean,
	TopBarEnabled: boolean,
	CreateIcon: (properties: {string | number}) -> (TopBarIcon),
	CreateSpacer: (properties: {string | number}) -> (TopBarSpacer),
	SetTopBarEnabled: (enabled: boolean) -> ()
}

if not RunService:IsClient() then
	error("Can only run UIShelf locally")
end

-- // Functions

--[=[
	Creates a new topbar icon, with declared properties.

	@param properties {string | number} -- The properties to set on the icon
	@return TopBarIconObject
]=]
function UIShelf.CreateIcon(properties: {string | number}): TopBarIcon?
	local self = setmetatable({ }, TopBarIconObject)
	local IconClone = TopbarIcon:Clone()

	local IconBackground = IconClone.Background
	local IconImage = IconBackground.Icon
	local IconStateOverlay = IconBackground.StateOverlayRound

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
	self._Tooltip = nil
	self._TooltipTweens = nil
	self.TooltipText = ""
	self.Name = properties[1]
	self.Image = properties[2]
	self.Order = properties[3]
	self.Area = properties[4] or 1

	self.StateChanged = Signal.NewController("StateChanged")
	self.Activated = Signal.NewController("Activated")
	self.NoticeAdded = Signal.NewController("NoticeAdded")
	self.NoticeRemoved = Signal.NewController("NoticeRemoved")

	self.Notices = 0
	self.NoticeCap = "99+"
	self.NoticeCapNum = 99
	self.CurrentState = "Default"

	self._KeyCodeConnections = nil
	self._NoticeConnection = nil
	self._TooltipConnection = nil
	self._GuiBindConnection = nil
	
	for connection, state in EVENTS_FOR_CONNECTION_ICON do
		IconBackground[connection]:Connect(function()
			self:UpdateStateOverlay(state)
		end)
	end
	
	self.StateChanged:Connect(function(data)
		local NewState = data[1]
		
		if not self._Tooltip then
			return
		end
		
		if NewState == "MouseUpHovering" or NewState ~= "Hovering" then
			self:SetTooltipEnabled(false)
			return
		end
		
		task.wait(0.75)
		
		local LatestState = self.CurrentState
			
		if LatestState == "Hovering" and self._Tooltip then
			self:SetTooltipEnabled(true)
		end
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
	UIShelf.TopBarEnabled = enabled
end

--[=[
	Sets the status of the icon visibility.

	@param enabled boolean -- Whether or not to enable the icon
]=]
function TopBarIconObject:SetIconEnabled(enabled: boolean)
	self._Element.Visible = enabled
end

--[=[
	Binds a GuiObject to the icon. This will toggle the visibility to the opposite when the icon is clicked.

	@param guiObject GuiObject -- The [GuiObject] to bind to activation, set to nil to unbind
]=]
function TopBarIconObject:BindGuiObject(guiObject: GuiObject?)
	if not guiObject then
		self._GuiBindConnection:Disconnect()
		return
	end
	
	if not self._GuiBindConnection then
		self._GuiBindConnection = self.Activated:Connect(function()
			guiObject.Visible = not guiObject.Visible
		end)
	end
end

--[=[
	Adds a tooltip to the icon when hovering.

	@param text string? -- The text to put in the tooltip, leave this nil to remove the tooltip
]=]
function TopBarIconObject:SetTooltip(text: string?)
	if not text then
		self._Tooltip:Destroy()
		self._Tooltip = nil
		
		for key, tween in self._TooltipTweens do
			tween:Destroy()
		end
		
		table.clear(self._TooltipTweens)
		
		return
	end
	
	if not self._Tooltip then
		self._Tooltip = IconTooltip:Clone()
		self._Tooltip.Parent = TooltipScreenGui
		
		self._TooltipTweens = {
			[false] = TweenService:Create(self._Tooltip, DEFAULT_TRANSPARENCYOUT_TWEENINFO, {
				GroupTransparency = 1
			}),
			[true] = TweenService:Create(self._Tooltip, DEFAULT_TRANSPARENCYIN_TWEENINFO, {
				GroupTransparency = 0
			}),
		}
	end
	
	local IconTooltip = self._Tooltip
	local TooltipCaret = IconTooltip.Caret
	local TooltipHeader = IconTooltip.Box.Header
	local TopBarIcon = self._Element
	
	if TooltipHeader.Text == text then
		return
	end
	
	TooltipHeader.Text = text
	
	local TOOLTIP_POSITION = TopBarIcon.AbsolutePosition.X + (TopBarIcon.AbsoluteSize.X / 2)
	local SHADOW_SIZE = self._Tooltip.Box.AbsoluteSize.X + 8
	
	IconTooltip.Position = UDim2.fromOffset(TOOLTIP_POSITION, 50)
	IconTooltip.Size = UDim2.fromOffset(SHADOW_SIZE, 53)
	IconTooltip.DropShadow.Size = UDim2.fromOffset(SHADOW_SIZE, 48)
	
	if not self._TooltipConnection then
		local ConnectionDebounce = false
		
		self._TooltipConnection = GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
			if ConnectionDebounce then
				return
			end
			
			ConnectionDebounce = true
			
			task.wait(0.25)
			IconTooltip.Position = UDim2.fromOffset(TopBarIcon.AbsolutePosition.X + (TopBarIcon.AbsoluteSize.X / 2), 50)
			ConnectionDebounce = false
		end)
	end
end

--[=[
	Sets the tooltips visibility forcibly.

	@param enabled boolean -- Whether or not the tooltip should show
]=]
function TopBarIconObject:SetTooltipEnabled(enabled: boolean)
	if not self._Tooltip then
		Debugger.Debug(error, "Icon must already have a tooltip set")
		return
	end
	
	self._Tooltip:TweenPosition(
		UDim2.fromOffset(self._Tooltip.Position.X.Offset, enabled and 50 or 46),
		enabled and Enum.EasingDirection.In or Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.15
	)
	
	if enabled then
		self._Tooltip.Visible = enabled
		self._TooltipTweens[enabled]:Play()
	else
		self._TooltipTweens[enabled]:Play()
		task.wait(0.15)
		self._Tooltip.Visible = enabled
	end
end

function TopBarIconObject:CreateContextMenu(contextMenuContents: {{string | number | () -> ()}})
	local TopBarIcon = self._Element
	local MenuContainer = TopBarIcon.ContextMenuContainer
	
	if MenuContainer.ScrollingFrame:FindFirstChildOfClass("ImageButton") then
		for _, instance in MenuContainer.ScrollingFrame:GetChildren() do
			if instance:IsA("ImageButton") then
				instance:Destroy()
			end
		end
	end
	
	for _, menuContents in contextMenuContents do
		if type(menuContents[2]) == "number" then
			menuContents[2] = `rbxassetid://{menuContents[2]}`
		end
		
		local ContextMenuObjectClone = ContextMenuObject:Clone()
		local ContextMenuObjectLabel = ContextMenuObjectClone.StyledTextLabel
		local ContextMenuObjectIcon = ContextMenuObjectClone.IconHost.IntegrationIconFrame.IntegrationIcon
		
		for connection, state in EVENTS_FOR_CONNECTION_MENU do
			ContextMenuObjectClone[connection]:Connect(function()
				if connection == "MouseButton1Up" then
					MenuContainer.Visible = false
					if menuContents[3] then
						menuContents[3]()
					end
				end
				
				self:_UpdateStateOverlayMenu(state, ContextMenuObjectClone)
			end)
		end
		
		ContextMenuObjectClone.Name = string.lower(menuContents[1])
		ContextMenuObjectLabel.Text = menuContents[1]
		ContextMenuObjectIcon.Image = menuContents[2]
		
		ContextMenuObjectClone.Parent = MenuContainer.ScrollingFrame
	end
	
	MenuContainer.Position = UDim2.new(CONTEXTMENU_POSITIONS[self.Area], 0, 0, 54)
	
	self.Activated:Connect(function()
		MenuContainer.Visible = not MenuContainer.Visible
	end)
end

function TopBarIconObject:_UpdateStateOverlayMenu(newState: "Default" | "Hovering" | "MouseDown", button: ImageButton)
	for property, value in STATEOVERLAY_CONTEXTMENU_PROPERTIES[newState] do
		button[property] = value
	end
end

function TopBarIconObject:UpdateStateOverlay(newState: "Default" | "Hovering" | "MouseDown" | "MouseUpHovering")
	local IconBackground = self._Element.Background
	local IconStateOverlay = IconBackground.StateOverlayRound
	
	if newState == "Hovering" and UserInputService.TouchEnabled then
		IconStateOverlay.Transparency = 0.7
		IconStateOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		return
	end
	
	if newState == "MouseUpHovering" then
		if UserInputService.MouseEnabled then
			self.Activated:Fire(Enum.UserInputType.MouseButton1)
		elseif UserInputService.TouchEnabled then
			self.Activated:Fire(Enum.UserInputType.Touch)
		end
	end
	
	for property, value in STATEOVERLAY_PROPERTIES[newState] do
		IconStateOverlay[property] = value
	end
	
	self.CurrentState = newState
	self.StateChanged:Fire(newState)
end

--[=[
	Sets the image rect size and offset. Useful if you are using a spritesheet image.

	@param rectSize Rect -- The [ImageLabel.ImageRectSize]
	@param rectOffset Rect -- The [ImageLabel.ImageRectOffset]
]=]
function TopBarIconObject:SetImageRect(rectSize: Rect, rectOffset: Rect)
	local IconImage = self._Element.Icon
	
	IconImage.ImageRectOffset = rectOffset
	IconImage.ImageRectSize = rectSize
end

--[=[
	Adds notices to the parent topbar icon.

	@param notices number? -- The amount of notices to add, leaving this nil will add a single notice
	@param noticeCap number? -- When to display a + sign after a set amount of notices, defaults to 99
]=]
function TopBarIconObject:AddIconNotices(notices: number?, noticeCap: number?)
	notices = notices or 1
	noticeCap = noticeCap or 99

	if notices <= 0 then
		Debugger.Debug(error, "Cannot notify 0 notifications")
		return
	end
	
	local TopBarIcon = self._Element
	local BadgeContainer = TopBarIcon.BadgeContainer

	if not BadgeContainer:FindFirstChild("Badge") then
		local TopbarIconBadgeClone = TopbarIconBadge:Clone()
		TopbarIconBadgeClone.Parent = BadgeContainer
	end

	local Badge = BadgeContainer.Badge
	local BadgeText = Badge.Inner.TextLabel
	
	if noticeCap and noticeCap ~= self.NoticeCapNum then
		self.NoticeCap = `{noticeCap}+`
	end

	if not self._NoticeConnection then
		self._NoticeConnection = TopBarIcon:GetAttributeChangedSignal("Notices"):Connect(function()
			local NewValue = TopBarIcon:GetAttribute("Notices")
			BadgeText.Text = NewValue

			if NewValue >= 1 then
				BadgeContainer.Visible = true
			elseif NewValue == 0 then
				BadgeContainer.Visible = false
				self.Notices = 0
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

	TopBarIcon:SetAttribute("Notices", TopBarIcon:GetAttribute("Notices") + notices)

	self.NoticeAdded:Fire(TopBarIcon:GetAttribute("Notices"))
	self.Notices += notices
end

--[=[
	Removes notices that are active in the icon.

	@param notices number? -- The amount of notices to remove, leave nil to remove all notices
]=]
function TopBarIconObject:RemoveIconNotices(notices: number?)
	local TopBarIcon = self._Element
	
	if not notices then
		TopBarIcon:SetAttribute("Notices", 0)
		self.Notices = 0
		return
	end
	
	if notices <= 0 then
		Debugger.Debug(error, "Cannot remove 0 notifications")
		return
	end
	
	TopBarIcon:SetAttribute(
		"Notices",
		TopBarIcon:GetAttribute("Notices")
		- notices
	)
	
	self.Notices -= notices
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
	@param bypass boolean? -- Allows you to bypass the order restrictions, should only be used internally

	@return TopBarSpacerObject
]=]
function UIShelf.CreateSpacer(properties: {string | number}, bypass: boolean?): TopBarSpacer?
	local self = setmetatable({ }, TopBarSpacerObject)
	local SpacerClone = TopbarSpacer:Clone()

	if properties[2] <= 0 and not bypass then
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
	Sets the size of the spacer on the X scale.

	@param size number -- The size to set the spacer to
]=]
function TopBarSpacerObject:SetSpacerSize(size: number)
	local TopBarSpacer = self._Element

	TopBarSpacer.Size = UDim2.fromOffset(size, TopBarSpacer.Size.Y.Offset)
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

-- // Actions

if VoiceChatService:IsVoiceEnabledForUserIdAsync(Player.UserId) and UIShelf.VoiceChatEnabled then
	local Spacer = UIShelf.CreateSpacer({
		"VoiceChatSpacer",
		-999,
		1,
	}, true)
		
	Spacer:SetSpacerSize(54)
end

local function UpdateTopBarInset()
	local CurrentTopBarInset = GuiService.TopbarInset
	
	for _, frame in TOPBAR_FRAMES do
		frame.Size = UDim2.fromOffset(CurrentTopBarInset.Width, CurrentTopBarInset.Height)
		frame.Position = UDim2.fromOffset(CurrentTopBarInset.Min.X, CurrentTopBarInset.Min.Y)
	end
end

GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(UpdateTopBarInset)

GuiService.MenuOpened:Connect(function()
	TopbarScreenGui.Enabled = false
end)

GuiService.MenuClosed:Connect(function()
	TopbarScreenGui.Enabled = UIShelf.TopBarEnabled
end)

UpdateTopBarInset()

return UIShelf :: UIShelf