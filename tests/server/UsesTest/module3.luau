local Lumin = require(game.ReplicatedStorage.Packages.framework)
local E = {
    Goodbye = nil
}
E.Init = function()
    E.Goodbye = function()
        return "Goodbye"
    end :: any
end
print("HI 3")
return Lumin.New(E)
