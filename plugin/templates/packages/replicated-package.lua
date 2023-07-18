-- // Package

local Package = { }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Framework = ReplicatedStorage.CanaryEngineFramework

local CanaryEngine = require(Framework.CanaryEngine.Package)
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