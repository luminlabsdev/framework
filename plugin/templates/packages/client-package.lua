-- // Package

local Package = { }

local CanaryEngine = require(game:GetService("ReplicatedStorage").CanaryEngineFramework.CanaryEngine)
local PackageClient = CanaryEngine.GetPackageClient(script.Vendor)

local Vendor = PackageClient.Vendor

-- // Variables

-- // Functions

function Package.myFunction()
	print("Hello, package function!")
end

-- // Connections

-- // Actions

print("Hello, package!")

return Package