--[[
	  by PLAYER_USERNAME
--]]

-- // Package

local Package = { }
local Vendor = script.Parent.Vendor

local CanaryEngine = require(game.ReplicatedStorage.Framework.Init)
local FrameworkClient = CanaryEngine.GetFrameworkClient()

-- // Variables

-- // Functions

function Package.myFunction()
	print("Hello, package function!")
end

-- // Connections

-- // Actions

return Package