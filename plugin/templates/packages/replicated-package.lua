-- // Package

local Package = { }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CanaryEngine = require(ReplicatedStorage.CanaryEngineFramework.CanaryEngine)
local EngineReplicated = CanaryEngine.GetEngineReplicated()

local Vendor = script.Vendor

-- // Variables

-- // Functions

function Package.myFunction()
	print("Hello, package function!")
end

-- // Connections

-- // Actions

print("Hello, package!")

return Package