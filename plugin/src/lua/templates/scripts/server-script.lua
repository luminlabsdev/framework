-- // Engine

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CanaryEngine = require(ReplicatedStorage.CanaryEngineFramework.CanaryEngine)
local EngineServer = CanaryEngine.GetEngineServer()

local Packages = ServerStorage.EngineServer.Packages
local Media = ServerStorage.EngineServer.Media

-- // Variables

local variable = 1

-- // Functions

-- // Connections

-- // Actions

print("Hello, server!")