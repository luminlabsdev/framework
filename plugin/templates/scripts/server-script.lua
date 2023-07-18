-- // Engine

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Framework = ReplicatedStorage.CanaryEngineFramework

local CanaryEngine = require(Framework.CanaryEngine.Script)
local EngineServer = CanaryEngine.GetEngineServer()

local Packages = EngineServer.Packages
local Media = EngineServer.Media

-- // Variables

-- // Functions

local function myFunction()
	print("Hello, function!")
end

-- // Connections

-- // Actions

print("Hello, server!")