-- // Engine

local CanaryEngine = require(game:GetService("ReplicatedStorage").CanaryEngineFramework.CanaryEngine)
local EngineClient = CanaryEngine.GetEngineClient()

local Packages = EngineClient.Packages
local Media = EngineClient.Media

-- // Variables

-- // Functions

local function myFunction()
	print("Hello, function!")
end

-- // Connections

-- // Actions

print("Hello, client!")