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
	  		by PLAYER_USERNAME

			-- // Package

			local Package = { }
			local Vendor = script.Parent.Vendor

			local CanaryEngine = require(game.ReplicatedStorage.Framework.Init)
			local Framework_FRAMEWORK_TYPE_ = CanaryEngine.GetFramework_FRAMEWORK_TYPE_()

			-- // Variables

			-- // Functions

			function Package.myFunction()
				print("Hello, package function!")
			end

			-- // Connections

			-- // Actions

			return Package
		]],

		Script = [[
			by PLAYER_USERNAME

			-- // Script
			
			local CanaryEngine = require(game.ReplicatedStorage.Framework.Init)
			local Framework_FRAMEWORK_TYPE_ = CanaryEngine.GetFramework_FRAMEWORK_TYPE_()
			
			-- // Variables
			
			-- // Functions
			
			-- // Connections
			
			-- // Actions
			
			print("Hello, _FRAMEWORK_TYPE_!")
		]],

		SpecialScript = [[
			by PLAYER_USERNAME

			-- // Engine
			
			local FrameworkLoader = require(script.Parent.Parent.FrameworkLoader.Init)
			
			-- // Variables
			
			-- // Functions
			
			-- // Connections
			
			-- // Actions
			
			print("Hello, _FRAMEWORK_TYPE_!")
		]],
	},
}