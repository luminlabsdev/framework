--[[
	  by PLAYER_USERNAME
	  CREATE_DATE @ CREATE_TIME
--]]

-- // Package

local Package = { }
local Vendor = script.Parent.Vendor

local CanaryEngine = require(game.ReplicatedStorage.Framework.Init)
local FrameworkServer = CanaryEngine.GetFrameworkServer()

-- // Variables

-- // Functions

function Package.myFunction()
	print("Hello, package function!")
end

-- // Connections

-- // Actions

return Package