-- // Script

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local CanaryEngine = require(ReplicatedStorage.Framework.Init)
local EngineServer = CanaryEngine.GetEngineServer()

local Packages = ServerStorage.EngineServer.Packages
local Media = ServerStorage.EngineServer.Media

-- // Variables

-- // Functions

-- // Connections

-- // Actions

print("Hello, server!")