-- // Package

local EngineLoader = { }
local Vendor = script.Vendor

-- // Variables

local PlayerService = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProviderService = game:GetService("ContentProvider")
local StarterGuiService = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Player = PlayerService.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local InterfaceClone = Vendor.EngineLoaderInterface:Clone()
local MainContainer = InterfaceClone.Container

local LoadingText = MainContainer.LoadingText
local LoadingSpinner = MainContainer.LoadingSpinner

local TitleInTween = TweenService:Create(LoadingText, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {TextTransparency = 0})
local TitleOutTween = TweenService:Create(LoadingText, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 1})
local LoadingSpinnerInTween = TweenService:Create(LoadingSpinner, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {ImageTransparency = 0})
local LoadingSpinnerOutTween = TweenService:Create(LoadingSpinner, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 1})

local InterfaceFinishedTweens = { }
local ConnectionsToClean = { }

local Sprite = require(Vendor.Sprite)

EngineLoader.IsClientLoaded = false

-- // Functions

function EngineLoader.StartLoad(objectsToLoad: {any}, loadingMessages: {[string]: Color3}?, coreGuiEnabled: boolean?, afterLoadWait: number?, loadingText: {loadingAssetsText: string, loadedAssetsText: string}?)
	if not script.Parent.Parent:GetAttribute("CanaryEngineLoaderEnabled") then
		return
	end
	
	task.spawn(function()
		loadingMessages = loadingMessages or { }
		afterLoadWait = afterLoadWait or 5
		loadingText = loadingText or {
			loadingAssetsText = "loading assets...",
			loadedAssetsText = "finished loading assets"
		}
		
		if coreGuiEnabled == nil then
			coreGuiEnabled = false
		end

		StarterGuiService:SetCoreGuiEnabled(Enum.CoreGuiType.All, coreGuiEnabled)
		InterfaceClone.Parent = PlayerGui
		
		task.defer(Sprite.Animate, LoadingSpinner, Vector2.new(1296, 1296), Vector2.new(9, 9), 35)
		task.wait(5)
		
		TitleInTween:Play()
		LoadingSpinnerInTween:Play()

		task.wait(1.5)

		local CurrentAssetIndex = 0
		local CurrentFailedAssetIndex = 0
		local TotalAssets = #objectsToLoad
		local LoadTimerEnd = 0

		local LoadTimer = os.clock()

		if TotalAssets >= 1 then
			ContentProviderService:PreloadAsync(objectsToLoad, function(_, fetchStatus: Enum.AssetFetchStatus)
				CurrentAssetIndex += 1

				if fetchStatus == Enum.AssetFetchStatus.TimedOut or fetchStatus == Enum.AssetFetchStatus.Failure then
					CurrentFailedAssetIndex += 1
				end

				local CurrentAssetIndexPercentage = math.ceil((CurrentAssetIndex / TotalAssets) * 100)
				LoadingText.Text = `{loadingText.loadingAssetsText} ({CurrentAssetIndexPercentage}%)`
			end)
		end
		
		task.wait(0.5)
		
		LoadTimerEnd = math.ceil(os.clock() - LoadTimer)
		EngineLoader.IsClientLoaded = true
		
		if EngineLoader.IsClientLoaded then
			LoadingSpinnerOutTween:Play()
			LoadingSpinnerOutTween.Completed:Once(function()
				Sprite.StopAnimation(LoadingSpinner)
			end)

			local RegularText = `{loadingText.loadedAssetsText} ({LoadTimerEnd}s)`
			local AdvancedText = `{loadingText.loadedAssetsText}:\ntime {LoadTimerEnd}s, total: {CurrentAssetIndex}, failed: {CurrentFailedAssetIndex}`

			LoadingText.Text = RegularText

			table.insert(ConnectionsToClean, LoadingText.MouseEnter:Connect(function()
				LoadingText.Text = AdvancedText
			end))

			table.insert(ConnectionsToClean, LoadingText.MouseLeave:Connect(function()
				LoadingText.Text = RegularText
			end))
		end

		task.wait(afterLoadWait)

		for _, connection: RBXScriptConnection in ConnectionsToClean do
			connection:Disconnect()
		end

		for stringToDisplay, textColor3 in loadingMessages :: {[string]: Color3} do
			TitleOutTween:Play()
			TitleOutTween.Completed:Wait()

			LoadingText.Text = stringToDisplay
			LoadingText.TextColor3 = textColor3

			TitleInTween:Play()
			task.wait(4.5)
		end

		for _, tweenToPlay in InterfaceFinishedTweens do
			tweenToPlay:Play()
		end

		StarterGuiService:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
		task.delay(0.35, InterfaceClone.Destroy, InterfaceClone)
	end)
end

function EngineLoader.CustomizeInterface(interfaceProperties: {
		Container: {
			BackgroundColor3: Color3?,
			BackgroundTransparency: number?,
		}?,
	
		LoadingText: {
			TextColor3: Color3?,
			FontFace: Font?,
			Visible: boolean?,
			Position: UDim2?,
		}?,
	
		LoadingSpinner: {
			ImageColor3: Color3?,
			Visible: boolean?,
			Position: UDim2?,
		}?
	})
	
	for interfaceSettingType, interfaceSettings in interfaceProperties do
		if type(interfaceSettings) == "table" then
			for property, value in interfaceSettings do
				InterfaceClone:FindFirstChild(interfaceSettingType, true)[property] = value
			end
		end
	end
end

-- // Connections

-- // Actions

ReplicatedFirst:RemoveDefaultLoadingScreen()

for _, guiObject in InterfaceClone:GetDescendants() do
	if guiObject:IsA("GuiObject") then
		table.insert(InterfaceFinishedTweens, TweenService:Create(guiObject, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1}))
	end
end

return EngineLoader