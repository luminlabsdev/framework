-- // Engine

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CanaryEngine = require(ReplicatedStorage.CanaryEngineFramework.CanaryEngine)
local EngineClient = CanaryEngine.GetEngineClient()

local Packages = ReplicatedStorage.EngineClient.Packages
local Media = ReplicatedStorage.EngineClient.Media

-- // Variables

local variable = 1

-- // Functions

-- // Connections

-- // Actions

print("Hello, client!")