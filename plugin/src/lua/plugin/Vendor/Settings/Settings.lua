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
	CanaryStudioInstanceTemplates = {
		ModuleScript = {
			Client = "https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/src/lua/templates/packages/package/client-package.luau",
			Server = "https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/src/lua/templates/packages/package/server-package.luau",
			Replicated = "https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/src/lua/templates/packages/package/replicated-package.luau",
		},
		Script = {
			Server = "https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/src/lua/templates/scripts/server-script.luau",
			Client = "https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/src/lua/templates/scripts/client-script.luau",
		}
	},
}