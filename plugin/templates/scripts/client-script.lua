-- // Engine

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CanaryEngine = require(ReplicatedStorage.CanaryEngineFramework.CanaryEngine)
local EngineClient = CanaryEngine.GetEngineClient()

local Packages = ReplicatedStorage.EngineClient.Packages
local Media = ReplicatedStorage.EngineClient.Media

-- // Variables

-- // Functions

local function myFunction()
	print("Hello, function!")
end

-- // Connections

-- // Actions

print("Hello, client!")