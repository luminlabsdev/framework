local Lumin = require(game.ReplicatedStorage.Packages.framework)
local Module3 = require(script.Parent.module4)
print("HI 3")
return Lumin.Controller("Module4", {
    Init = function()
        local success, err = pcall(function()
            print((Module3 :: any).Goodbye())
        end)
        print(success, err)
    end
})