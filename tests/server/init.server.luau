local Lumin = require(game.ReplicatedStorage.Packages.framework)
local Modules = script.Modules
local ExpectTest = script.ExpectTest

Lumin.Start({Modules, ExpectTest}):andThen(function()
    print("Server started")
end)
