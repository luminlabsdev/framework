local Lumin = require(game.ReplicatedStorage.Packages.framework)

local function Init()
    print("Init")
end

local function Start()
    print("Start")
end

return Lumin.New {
    Init = Init,
    Start = Start,
}
