local Lumin = require(game.ReplicatedStorage.Packages.framework)
local Players = game:GetService("Players")

local Cycle = Lumin.Cycle("PlrAdd")
Players.PlayerAdded:Connect(function(player)
    Cycle:Fire(player)
end)

local function Init()
    print("Init")
end

local function Start()
    print("Start")
end

local function PlrAdd(player: Player)
    print(player.Name, "said Hello")
end

return Lumin.New {
    Init = Init,
    Start = Start,
    PlrAdd = PlrAdd,
}
