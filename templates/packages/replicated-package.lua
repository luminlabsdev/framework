-- // Package

local Package = { }

local CanaryEngine = require(game:GetService("ReplicatedStorage").CanaryEngineFramework.CanaryEngine)
local Vendor = script:WaitForChild("Vendor")

-- // Variables

-- // Functions

function Package.myFunction()
	print("Hello, package function!")
end

-- // Connections

-- // Actions

print("Hello, package!")

return Package