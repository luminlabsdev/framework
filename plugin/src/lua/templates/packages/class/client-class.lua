-- // Package

local Package = { }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CanaryEngine = require(ReplicatedStorage.CanaryEngineFramework.CanaryEngine)
local EngineClient = CanaryEngine.GetEngineClient()

local Vendor = script.Vendor

-- // Variables

Package.__index = Package

-- // Functions

function Package.new()
	local self = setmetatable({ }, Package)

	return self
end

function Package:Method()
	print("Hello, method!")
end

-- // Connections

-- // Actions

return Package