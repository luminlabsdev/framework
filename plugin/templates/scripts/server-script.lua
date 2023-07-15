-- // Engine

local CanaryEngine = require(game:GetService("ReplicatedStorage").CanaryEngineFramework.CanaryEngine)
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