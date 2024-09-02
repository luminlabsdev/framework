local Lumin = require(game.ReplicatedStorage.Packages.framework)
local Module1 = require(script.Parent.module2)

print("HI 1")

return Lumin.New({
    Uses = {Module1},
    Init = function()
        print(Module1.Goodbye())
    end
})
