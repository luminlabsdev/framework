return {
    CanaryStudio = {
        ["Select / Open New Instances"] = true,
        ["Default Instance Templates"] = true,
        ["Automatically Update Canary"] = false,
        ["Create Package Vendor"] = true,
    },

    CanaryStudioInstaller = {
        ["Studio Debugging"] = true,
        ["Live Game Debugging"] = false,
        ["Enable Media Templates"] = true,
    },

    CanaryStudioInstallerPackages = { },
    CanaryStudioManagerPackages = { },
    CanaryStudioInstanceTemplates = {
        ModuleScript = {
            Client = "https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/src/lua/templates/packages/package/client-package.lua",
            Server = "https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/src/lua/templates/packages/package/server-package.lua",
            Replicated = "https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/src/lua/templates/packages/package/replicated-package.lua",
        },
        Script = {
            Server = "https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/plugin/src/lua/templates/scripts/server-script.lua",
            Client = "https://raw.githubusercontent.com/canary-development/CanaryEngine/main/plugin/plugin/src/lua/templates/scripts/client-script.lua",
        }
    },
}