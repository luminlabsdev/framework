local Lumin = require(game.ReplicatedStorage.Packages.framework)
local Module3 = require(script.Parent.module3)
print("HI 4")
return Lumin.New({
    Init = function()
        local success, err = pcall(function()
            print((Module3 :: any).Goodbye())
        end)
        print(success, err)
    end
})
