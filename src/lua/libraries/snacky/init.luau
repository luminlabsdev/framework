-- // Package

local Snacky = { }
local HintObject = { }

local Vendor = script.Parent.Vendor

-- // Variables

local PlayerService = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Signal = require(Vendor.Signal)

local Player = PlayerService.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

local HintScreenGui = Vendor.Hints
local HintObjectGui = Vendor.HintObject

local HintInTweenInfoDefault = TweenInfo.new(
	0.8,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In
)

local HintOutTweenInfoDefault = TweenInfo.new(
	0.8,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local HintBroadcastAreas = {
	"LeftFrame",
	"CenterFrame",
	"RightFrame"
}

Snacky.BroadcastStyle = {
	Animated = 1,
	Static = 2,
}

Snacky.BroadcastArea = {
	Left = 1,
	Center = 2,
	Right = 3,
}

Snacky.BroadcastTime = {
	Infinite = 1,
	Set = 2,
}

HintObject.__index = HintObject

HintScreenGui.Parent = PlayerGui
HintScreenGui.Archivable = false

-- // Functions

function Snacky.CreateHint(properties: {string | number | Enum.EasingStyle})
	local self = setmetatable({ }, HintObject)
	local HintClone = HintObjectGui:Clone()
	
	self._Element = HintClone
	
	self.BroadcastArea = properties[2] or Snacky.BroadcastArea.Center
	self.BroadcastStyle = properties[3] or Snacky.BroadcastStyle.Animated
	self.BroadcastTime = properties[4] or Snacky.BroadcastTime.Set
	self.BroadcastText = ""
	self.CurrentBroadcastCancelled = false
	self.CurrentlyBroadcasting = false
	
	self.BroadcastFinished = Signal() :: Signal.Signal<>
	self.BroadcastStarted = Signal() :: Signal.Signal<>
	
	self._BroadcastCancelled = Signal()
	self._ActivatedConnection = nil
	self._TweenTime = properties[6]
	self._TweenStyle = properties[5]
	self._Tweens = {
		[true] = nil,
		[false] = nil,
	}
	
	HintClone.Name = properties[1]
	HintClone.Parent = HintScreenGui.HintsFrame:FindFirstChild(
		HintBroadcastAreas[self.BroadcastArea]
	)
	
	if self.BroadcastStyle == Snacky.BroadcastStyle.Animated then
		local TweenInfoToUse = {
			In = nil,
			Out = nil,
		}
		
		if properties[5] and properties[6] then
			TweenInfoToUse.In = TweenInfo.new(
				properties[6] :: number,
				properties[5] :: Enum.EasingStyle,
				Enum.EasingDirection.In
			)
			
			TweenInfoToUse.Out = TweenInfo.new(
				properties[6] :: number,
				properties[5] :: Enum.EasingStyle,
				Enum.EasingDirection.Out
			)
		else
			TweenInfoToUse.In = HintInTweenInfoDefault
			TweenInfoToUse.Out = HintOutTweenInfoDefault
		end
		
		self._Tweens[true] = {
			Background = TweenService:Create(self._Element, TweenInfoToUse.In, {BackgroundTransparency = 0.3}),
			Text = TweenService:Create(self._Element, TweenInfoToUse.In, {TextTransparency = 0})
		}
		
		self._Tweens[false] = {
			Background = TweenService:Create(self._Element, TweenInfoToUse.Out, {BackgroundTransparency = 1}),
			Text = TweenService:Create(self._Element, TweenInfoToUse.Out, {TextTransparency = 1})
		}
	end
	
	return self
end

function HintObject:SetStyle(properties: {
		CornerRadius: number?,
		TextColor3: number?,
		BackgroundColor3: number?,
		BackgroundTransparency: number?,
		FontFace: Font?,
	})
	
	local Element = self._Element
	
	for property, value in properties do
		if property == "CornerRadius" then
			Element.Corner.CornerRadius = UDim.new(0, value)
			continue
		end
		
		if property == "BackgroundTransparency" then
			self._Tweens[true].Background = TweenService:Create(Element, TweenInfo.new(
					self._TweenTime,
					self._TweenStyle,
					Enum.EasingDirection.In
				))
		end
		
		Element[property] = value
	end
end

function HintObject:SetOrder(order: number)
	self._Element.LayoutOrder = order
end

function HintObject:BindToActivated(func: (inputType: Enum.UserInputType) -> ())
	local Element: TextButton = self._Element
	
	Element.Active = true
	Element.AutoButtonColor = true
	
	self._ActivatedConnection = Element.Activated:Connect(function(input)
		func(input.UserInputType)
	end)
end

function HintObject:UnbindFromActivated()
	local Element: TextButton = self._Element
	
	Element.Active = false
	Element.AutoButtonColor = false
	
	self._ActivatedConnection:Disconnect()
	self._ActivatedConnection = nil
end

function HintObject:CancelBroadcast(destroy: boolean?)
	local Element: TextButton = self._Element
	
	self.CurrentBroadcastCancelled = true
	self._BroadcastCancelled:Fire()
	
	if self.BroadcastStyle == Snacky.BroadcastStyle.Animated then
		local TweenToPlay: Tween = self._Tweens[false]
		
		if destroy then
			TweenToPlay.Completed:Once(function()
				self:Destroy()
			end)
		end
		
		self.CurrentlyBroadcasting = false
		TweenToPlay:Play()
	elseif self.BroadcastStyle == Snacky.BroadcastStyle.Static then
		task.defer(function()
			Element.Visible = true
			task.wait(self._Tweens[false].TweenInfo.Time)
			Element.Visible = false

			if destroy then
				self:Destroy()
			end
		end)
	end
end

function HintObject:Broadcast(broadcastText: string, broadcastTime: number?, destroyWhenFinished: boolean?)
	local Element: TextButton = self._Element
	
	self.BroadcastText = broadcastText
	Element.Text = broadcastText
	
	task.defer(function()
		if self.BroadcastStyle == Snacky.BroadcastStyle.Animated then
			local TweenToPlay: Tween = self._Tweens[true]
			
			self._BroadcastCancelled:Connect(function()
				if self.CurrentBroadcastCancelled then
					self.CurrentlyBroadcasting = false
					return
				end

				local NewTweenToPlay: Tween = self._Tweens[false]

				if destroyWhenFinished then
					NewTweenToPlay.Completed:Once(function()
						self:Destroy()
					end)
				end

				self.CurrentlyBroadcasting = false
				NewTweenToPlay:Play()
			end)

			self.CurrentlyBroadcasting = true
			
			TweenToPlay:Play()
			task.wait(self._Tweens[true].TweenInfo.Time)
			Element.TextTransparency = 0
			task.wait(broadcastTime)
			self._BroadcastCancelled:Fire()
		elseif self.BroadcastStyle == Snacky.BroadcastStyle.Static then
			Element.Visible = true
			task.wait(broadcastTime)
			Element.Visible = false

			if self.CurrentBroadcastCancelled then
				return
			end

			if destroyWhenFinished then
				self:Destroy()
			end
		end
	end)
end

function HintObject:Destroy()
	self._Element:Destroy()
	
	for _, prop in HintObject do
		if typeof(prop) == "RBXScriptConnection" then
			prop:Disconnect()
		end
		
		prop = nil
	end
end

-- // Connections

Backpack.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then	
		HintScreenGui.HintsFrame.CenterFrame.Padding.PaddingBottom = UDim.new(0, 70)
	end
end)

Backpack.ChildRemoved:Connect(function(child)
	if child:IsA("Tool") then
		local Character = Player.Character
		
		if Character then
			local FoundChild = Character:FindFirstChild(child.Name)
			
			if FoundChild:IsA("Tool") then
				return
			end
		end
		
		if #Backpack:GetChildren() == 0 then
			HintScreenGui.HintsFrame.CenterFrame.Padding.PaddingBottom = UDim.new(0, 10)
		end
	end
end)

-- // Actions

return Snacky