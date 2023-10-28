return {
	CanaryStudio = {
		["Select / Open New Instances"] = true,
		["Default Instance Templates"] = true,
		["Automatically Update Canary"] = false,
		["Instance Author Attributes"] = false,
	},

	CanaryStudioInstaller = {
		["Studio Debugging"] = true,
		["Live Game Debugging"] = false,
		["Enable Asset Templates"] = true,
		["Install Recommended Libs"] = true, -- an option to install libraries like EasyProfile
	},

	CanaryStudioInstallerPackages = { },
	CanaryStudioManagerPackages = { },
	CanaryStudioManagerCustomPackages = { },

	CanaryStudioInstanceTemplates = {
		ModuleScript = [[
~AUTHOR~

-- // Package

local ~PACKAGE~NAME~ = { }

local CanaryEngine = require(game.ReplicatedStorage.Framework)
local Framework~FRAMEWORK~TYPE~ = CanaryEngine.GetFramework~FRAMEWORK~TYPE~()

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

local CanaryEngine = require(game.ReplicatedStorage.Framework)
local Framework~FRAMEWORK~TYPE~ = CanaryEngine.GetFramework~FRAMEWORK~TYPE~()

-- // Variables

-- // Functions

-- // Connections

-- // Actions

print("Hello, ~FRAMEWORK~TYPE~!")
]],

		SpecialScript = [[
~AUTHOR~

-- // Engine

local FrameworkLoader = require(script.Parent.Parent.FrameworkLoader.Init)

-- // Variables

-- // Functions

-- // Connections

-- // Actions

print("Hello, ~FRAMEWORK~TYPE~!")
]],
	},
}