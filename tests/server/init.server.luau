local Lumin = require(game.ReplicatedStorage.Packages.framework)
local Modules = script.Modules

Lumin.Start({Modules}):andThen(function()
    print("Server started")
end)
