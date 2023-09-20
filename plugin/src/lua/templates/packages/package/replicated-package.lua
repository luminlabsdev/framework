-- // Package

local Package = { }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CanaryEngine = require(ReplicatedStorage.Framework.Init)
local EngineReplicated = CanaryEngine.GetEngineReplicated()

local Vendor = script.Parent.Vendor

-- // Variables

-- // Functions

function Package.myFunction()
	print("Hello, package function!")
end

-- // Connections

-- // Actions

return Package