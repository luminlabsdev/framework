local Lumin = require(game.ReplicatedStorage.Packages.framework)
local Module1 = require(script.Parent.module2)
local expected = Lumin.Expect(Module1)

print("HI 1")

return Lumin.Controller("Module1", {
    Init = function()
        print(expected.Goodbye())
    end
})