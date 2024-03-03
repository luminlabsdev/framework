return {
	ModuleScript = [[
~AUTHOR~

-- // Package

local ~PACKAGE~NAME~ = { }

local Canary = require(game:GetService("ReplicatedStorage").Framework)
local Framework = Canary.GetFramework~FRAMEWORK~TYPE~()

-- // Variables

-- // Functions

function ~PACKAGE~NAME~.myFunction()
print("Hello, package function!")
end

-- // Connections

-- // Actions

return ~PACKAGE~NAME~
]],

	Script = [[
~AUTHOR~

-- // Script

local Canary = require(game:GetService("ReplicatedStorage").Framework)
local Framework = Canary.GetFramework~FRAMEWORK~TYPE~()

-- // Variables

-- // Functions

-- // Connections

-- // Actions

print("Hello, ~FRAMEWORK~TYPE~!")
]],
}
