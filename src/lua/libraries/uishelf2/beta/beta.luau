local UIShelf = { }
local TopBarIconObject = { }
local TopBarSpacerObject = { }
local TopBarUnibarObject = { }

-- // Variables

TopBarSpacerObject.__index = TopBarSpacerObject
TopBarIconObject.__index = TopBarIconObject
TopBarUnibarObject.__index = TopBarUnibarObject
UIShelf.__index = UIShelf

UIShelf.CreatedIcons = { }
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

local TopbarIconBadge = Vendor.Badge
local TopbarIcon = Vendor.Icon
local TopbarSpacer = Vendor.Spacer
local UnibarMenu = Vendor.UnibarMenu
local IconTooltip = Vendor.Tooltip
local MenuObject = Vendor.MenuObject

local Signal = require(Vendor.Signal)

local DEFAULT_TRANSPARENCYOUT_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local DEFAULT_TRANSPARENCYIN_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local NOTICE_UI_PADDING = 14
local NOTICE_UI_MARGIN = 24
local NOTICE_UI_MARGIN_24X24 = 0

local TOPBAR_FRAMES = {
	LeftFrame,
	RightFrame,
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

local STATEOVERLAY_MENU_PROPERTIES = {
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

local STATEOVERLAY_UNIBAR_PROPERTIES = {
	Default = {
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	},
	Hovering = {
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	},
	Open = {
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	}
}

local EVENTS_FOR_CONNECTION_ICON = {
	MouseButton1Up = "MouseUpHovering",
	MouseButton1Down = "MouseDown",
	MouseEnter = "Hovering",
	MouseLeave = "Default",
	SelectionGained = "Hovering",
	SelectionLost = "Default",
}

local EVENTS_FOR_CONNECTION_MENU = {
	MouseButton1Up = "Hovering",
	MouseButton1Down = "MouseDown",
	MouseEnter = "Hovering",
	MouseLeave = "Default",
}

local EVENTS_FOR_CONNECTION_UNIBAR = {
	MouseButton1Up = "Hovering",
	MouseButton1Down = "Hovering",
	MouseEnter = "Hovering",
	MouseLeave = "Default",
}

local VoiceSpacer

UIShelf.HorizontalAlignment = {
	Left = 1,
	Right = 2,
}

if PlayerGui:FindFirstChild("TopBarApp") then
	TopbarScreenGui:Destroy()
	TopbarScreenGui = PlayerGui:FindFirstChild("TopBarApp")
else
	TopbarScreenGui.Parent = PlayerGui
	TopbarScreenGui.Archivable = false
end

if PlayerGui:FindFirstChild("TooltipLayer") then
	TooltipScreenGui:Destroy()
	TooltipScreenGui = PlayerGui:FindFirstChild("TooltipLayer")
else
	TooltipScreenGui.Parent = PlayerGui
	TooltipScreenGui.Archivable = false
end

-- // Types

type IconProps = {
	Name: string,
	Image: string | number,
	Order: number,
	Area: number?,
	Text: string?,
}

type SpacerProps = {
	Name: string,
	Order: number,
	Area: number?,
}

type MenuItemProps = {
	Name: string,
	Image: string | number,
}

type Signal<T...> = {
	Connect: (self: Signal<T...>, Callback: (T...) -> ()) -> () -> (),
	Wait: (self: Signal<T...>) -> T...,
	Once: (self: Signal<T...>, Callback: (T...) -> ()) -> () -> (),
}

if not RunService:IsClient() then
	error("Can only run UIShelf locally")
end

-- // Functions

function UIShelf.CreateIcon(properties: IconProps)
	local self = setmetatable({ }, TopBarIconObject)
	local IconClone = TopbarIcon:Clone()

	local IconBackground = IconClone.Background
	local IconImage = IconBackground.Icon
	local IconStateOverlay = IconBackground.StateOverlayRound

	self._Element = IconClone
	self._Tooltip = nil
	self._TooltipTweens = nil
	self.TooltipText = ""
	
	self.Name = nil
	self.Image = nil
	self.Order = nil
	self.Area = nil
	
	self:SetProperties(properties)

	self.StateChanged = Signal() :: Signal<string>
	self.Activated = Signal() :: Signal<Enum.UserInputType>
	self.NoticeAdded = Signal() :: Signal<number>
	self.NoticeRemoved = Signal() :: Signal<number>

	self.Notices = 0
	self.NoticeCap = "99+"
	self.NoticeCapNum = 99
	self.CurrentState = "Default"

	self._KeyCodeConnection = nil
	self._NoticeConnection = nil
	self._TooltipConnection = nil
	self._GuiBindConnection = nil

	for connection, state in EVENTS_FOR_CONNECTION_ICON do
		IconBackground[connection]:Connect(function()
			self:UpdateStateOverlay(state)
		end)
	end

	self.StateChanged:Connect(function(newState)
		if not self._Tooltip then
			return
		end

		if newState == "MouseUpHovering" or newState ~= "Hovering" then
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

	IconClone.Name = properties.Name
	IconClone.LayoutOrder = properties.Order
	IconImage.Image = properties.Image

	table.insert(UIShelf.CreatedIcons, self)

	return self
end

function UIShelf.SetTopBarEnabled(enabled: boolean)
	TopbarScreenGui.Enabled = enabled
	UIShelf.TopBarEnabled = enabled
end

function TopBarIconObject:SetIconEnabled(enabled: boolean)
	self._Element.Visible = enabled
end

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

function TopBarIconObject:SetProperties(properties: IconProps)
	local IconBackground = self._Element.Background
	local IconText = IconBackground.Text
	
	if type(properties.Image) == "number" then
		properties.Image = `rbxassetid://{properties.Image}`
	end

	if properties.Order <= 0 then
		error("Order cannot be less than 0")
	end

	if properties.Area == UIShelf.HorizontalAlignment.Right then
		properties.Order = -properties.Order
	end

	if properties.Text then
		IconBackground.Text.Visible = true
		IconBackground.Text.Text = properties.Text
	end
	
	for name, value in properties do
		self[name] = value
	end
end

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

	IconTooltip.Position = UDim2.fromOffset(TOOLTIP_POSITION, 60)
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
			IconTooltip.Position = UDim2.fromOffset(TopBarIcon.AbsolutePosition.X + (TopBarIcon.AbsoluteSize.X / 2), 60)
			ConnectionDebounce = false
		end)
	end
end

function TopBarIconObject:SetTooltipEnabled(enabled: boolean)
	if not self._Tooltip then
		error("Icon must already have a tooltip set")
		return
	end

	self._Tooltip:TweenPosition(
		UDim2.fromOffset(self._Tooltip.Position.X.Offset, if enabled then 60 else 56),
		if enabled then Enum.EasingDirection.In else Enum.EasingDirection.Out,
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

function TopBarIconObject:CreateMenu(menuContents: {typeof(UIShelf.CreateMenuItem({Name = "", Image = 0}))})
	local TopBarIcon = self._Element
	local MenuContainer = TopBarIcon.MenuContainer

	if MenuContainer.ScrollingFrame:FindFirstChildOfClass("ImageButton") then
		for _, instance in MenuContainer.ScrollingFrame:GetChildren() do
			if instance:IsA("ImageButton") then
				instance:Destroy()
			end
		end
	end

	for _, menuContents in menuContents do
		local MenuObjectClone = MenuObject:Clone()
		local MenuObjectLabel = MenuObjectClone.StyledTextLabel
		local MenuObjectIcon = MenuObjectClone.IconHost.IntegrationIconFrame.IntegrationIcon

		for connection, state in EVENTS_FOR_CONNECTION_MENU do
			MenuObjectClone[connection]:Connect(function()
				if connection == "MouseButton1Up" then
					MenuContainer.Visible = false
					menuContents.Activated:Fire()
				end

				self:_UpdateStateOverlayMenu(state, MenuObjectClone)
			end)
		end

		MenuObjectClone.Name = string.lower(menuContents.Name)
		MenuObjectLabel.Text = menuContents.Name
		MenuObjectIcon.Image = menuContents.Image

		MenuObjectClone.Parent = MenuContainer.ScrollingFrame
	end

	MenuContainer.Position = UDim2.new(1, 0, 0, 54)
	
	if self.Area == UIShelf.HorizontalAlignment.Left then
		MenuContainer.Position = UDim2.fromOffset(0, 54)
		MenuContainer.AnchorPoint = Vector2.new(0, 0)
	end

	self.Activated:Connect(function()
		MenuContainer.Visible = not MenuContainer.Visible
	end)
end

function TopBarIconObject:_UpdateStateOverlayMenu(newState: "Default" | "Hovering" | "MouseDown", button: ImageButton)
	for property, value in STATEOVERLAY_MENU_PROPERTIES[newState] do
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

function TopBarIconObject:SetImageRect(rectSize: Rect, rectOffset: Rect)
	local IconImage = self._Element.Icon

	IconImage.ImageRectOffset = rectOffset
	IconImage.ImageRectSize = rectSize
end

function TopBarIconObject:AddIconNotices(notices: number?, noticeCap: number?)
	notices = notices or 1
	noticeCap = noticeCap or 99

	if notices <= 0 then
		error("Cannot notify 0 notifications")
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
				Badge.Position = UDim2.new(1, NOTICE_UI_MARGIN_24X24, 0, 0)
				return
			end
			
			Badge.Size = UDim2.fromOffset(BadgeText.TextBounds.X + NOTICE_UI_PADDING, 24)
			Badge.Position = UDim2.new(1, BadgeText.TextBounds.X + NOTICE_UI_PADDING - NOTICE_UI_MARGIN, 0, 0)
		end)
	end

	TopBarIcon:SetAttribute("Notices", TopBarIcon:GetAttribute("Notices") + notices)

	self.NoticeAdded:Fire(TopBarIcon:GetAttribute("Notices"))
	self.Notices += notices
end

function TopBarIconObject:RemoveIconNotices(notices: number?)
	local TopBarIcon = self._Element

	if not notices then
		TopBarIcon:SetAttribute("Notices", 0)
		self.Notices = 0
		return
	end

	if notices <= 0 then
		error("Cannot remove 0 notifications")
		return
	end

	TopBarIcon:SetAttribute(
		"Notices",
		TopBarIcon:GetAttribute("Notices")
		- notices
	)

	self.Notices -= notices
end

function TopBarIconObject:BindKeyCode(keyCode: Enum.KeyCode?)
	if not keyCode then
		if self._Tooltip then
			local HotKeyFrame = self._Tooltip.Box.Hotkeys
			local FirstHotKey = HotKeyFrame["1"]

			HotKeyFrame.Visible = false
			FirstHotKey.LabelContent.Text = "nil"
		end

		if self._KeyCodeConnection then
			self._KeyCodeConnection:Disconnect()
		end
		
		return
	end

	if self._Tooltip then
		local HotKeyFrame = self._Tooltip.Box.Hotkeys
		local FirstHotKey = HotKeyFrame["1"]
		
		HotKeyFrame.Visible = true
		FirstHotKey.LabelContent.Text = keyCode.Name
	end

	self._KeyCodeConnection = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
		if gameProcessedEvent then
			return
		end

		if input.KeyCode == keyCode then
			self.Activated:Fire(input.UserInputType)
		end
	end)
end

function TopBarIconObject:SetImageSize(imageSize: Vector2)
	local TopBarIcon = self._Element
	local TopBarIconImage = TopBarIcon.Background.Icon

	TopBarIconImage.Size = UDim2.fromOffset(imageSize.X, imageSize.Y)
end

function TopBarIconObject:Destroy()
	self._KeyCodeConnection:Disconnect()

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

function UIShelf.CreateSpacer(properties: SpacerProps, bypass: boolean?)
	local self = setmetatable({ }, TopBarSpacerObject)
	local SpacerClone = TopbarSpacer:Clone()

	if properties.Order <= 0 and not bypass then
		error("Order cannot be less than 0")
	end

	if properties.Area == 2 then
		properties.Order = -properties.Order
	end

	self._Element = SpacerClone
	self.Name = properties.Name
	self.Order = properties.Order
	self.Area = properties.Area

	if self.Area == 1 then
		SpacerClone.Parent = LeftFrame
	elseif self.Area == 2 then
		SpacerClone.Parent = RightFrame
	end

	SpacerClone.Name = properties[1]
	SpacerClone.LayoutOrder = properties[3]

	return self
end

function TopBarSpacerObject:SetSpacerEnabled(enabled: boolean)
	local TopBarSpacer = self._Element

	TopBarSpacer.Visible = enabled
end

function TopBarSpacerObject:SetSpacerSize(size: number)
	local TopBarSpacer = self._Element

	TopBarSpacer.Size = UDim2.fromOffset(size, TopBarSpacer.Size.Y.Offset)
end

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

function UIShelf.CreateMenuItem(properties: MenuItemProps)
	local MenuItemObject = { }

	if type(properties.Image) == "number" then
		properties.Image = `rbxassetid://{properties.Image}`
	end

	MenuItemObject.Name = properties.Name
	MenuItemObject.Image = properties.Image

	MenuItemObject.Activated = Signal() :: Signal<>

	return MenuItemObject
end

-- // Connections

GuiService.MenuOpened:Connect(function()
	TopbarScreenGui.Enabled = false
end)

GuiService.MenuClosed:Connect(function()
	TopbarScreenGui.Enabled = UIShelf.TopBarEnabled
end)

-- // Actions

local function UpdateTopbar()
	local Inset = GuiService.TopbarInset

	TopbarScreenGui.TopBarFrame.Size = UDim2.fromOffset(
		Inset.Width, TopbarScreenGui.TopBarFrame.Size.Y.Offset
	)

	TopbarScreenGui.TopBarFrame.Position = UDim2.fromOffset(
		Inset.Min.X, TopbarScreenGui.TopBarFrame.Position.Y.Offset
	)
end

GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(UpdateTopbar)

if UserInputService.TouchEnabled and UserInputService.GyroscopeEnabled then
	TopbarScreenGui.TopBarFrame.Position = UDim2.fromOffset(
		0, 4
	)
end

UpdateTopbar()

return UIShelf