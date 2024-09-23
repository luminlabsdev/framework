local Lumin = require(game.ReplicatedStorage.Packages.framework)
local E = {
    Test = {
        Goodbye = nil
    }
}
E.Init = function()
    E.Test.Goodbye = function()
        return "Goodbye"
    end :: any
end
print("HI 3")
return Lumin.New(E)
