return {
	CanaryStudio = {
		["Select / Open New Instances"] = true,
		["Default Instance Templates"] = true,
		["Automatically Update Canary"] = false,
		["Create Package Vendor"] = true,
		["Instance Author Attributes"] = false,
	},

	CanaryStudioInstaller = {
		["Studio Debugging"] = true,
		["Live Game Debugging"] = false,
		["Enable Asset Templates"] = true,
	},

	CanaryStudioInstallerPackages = { },
	CanaryStudioManagerPackages = { },
	CanaryStudioManagerCustomPackages = { },

	CanaryStudioInstanceTemplates = {
		ModuleScript = [[
+AUTHOR+

-- // Package

local +PACKAGE+NAME+ = { }
+VENDOR+

local CanaryEngine = require(game.ReplicatedStorage.Framework.Init)
local Framework+FRAMEWORK+TYPE+ = CanaryEngine.GetFramework+FRAMEWORK+TYPE+()

-- // Variables

-- // Functions

function +PACKAGE+NAME+.myFunction()
	print("Hello, package function!")
end

-- // Connections

-- // Actions

return +PACKAGE+NAME+
		]],

		Script = [[
+AUTHOR+

-- // Script
			
local CanaryEngine = require(game.ReplicatedStorage.Framework.Init)
local Framework+FRAMEWORK+TYPE+ = CanaryEngine.GetFramework+FRAMEWORK+TYPE+()
			
-- // Variables
			
-- // Functions
			
-- // Connections
			
-- // Actions
			
print("Hello, +FRAMEWORK+TYPE+!")
		]],

		SpecialScript = [[
+AUTHOR+

-- // Engine
			
local FrameworkLoader = require(script.Parent.Parent.FrameworkLoader.Init)
			
-- // Variables
			
-- // Functions
			
-- // Connections
			
-- // Actions
			
print("Hello, +FRAMEWORK+TYPE+!")
		]],
	},
}