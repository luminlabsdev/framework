-- // Engine

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Framework = ReplicatedStorage.CanaryEngineFramework

local CanaryEngine = require(Framework.CanaryEngine.Script)
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