-- // Engine

local ServerStorage = game:GetService("ServerStorage")
local CanaryEngine = require(game:GetService("ReplicatedStorage").CanaryEngineFramework.CanaryEngine)
local EngineServer = CanaryEngine.GetEngineServer()

local Packages = ServerStorage.EngineServer.Packages
local Media = ServerStorage.EngineServer.Media

-- // Variables

-- // Functions

local function myFunction()
	print("Hello, function!")
end

-- // Connections

-- // Actions

print("Hello, server!")