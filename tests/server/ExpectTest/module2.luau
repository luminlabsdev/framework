local Lumin = require(game.ReplicatedStorage.Packages.framework)
print("HI 2")
return Lumin.Controller("Module1", {
    Goodbye = function()
        return "Goodbye"
    end
})