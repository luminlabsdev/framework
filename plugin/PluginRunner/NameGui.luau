local Name = Instance.new("ScreenGui")
Name.Name = "Name"
Name.DisplayOrder = 1e+09
Name.IgnoreGuiInset = true
Name.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
Name.ResetOnSpawn = false
Name.Archivable = false

local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
MainContainer.BorderColor3 = Color3.fromRGB(64, 64, 64)
MainContainer.BorderSizePixel = 3
MainContainer.Size = UDim2.fromOffset(150, 50)

local TextBox = Instance.new("TextBox")
TextBox.Name = "TextBox"
TextBox.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
TextBox.PlaceholderText = "Name..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 18
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.AnchorPoint = Vector2.new(1, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BackgroundTransparency = 1
TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.fromScale(1, 0)
TextBox.Size = UDim2.fromScale(0.9, 1)
TextBox.Parent = MainContainer

MainContainer.Parent = Name
return Name
