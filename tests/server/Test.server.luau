local Canary = require(game.ReplicatedStorage.Packages.Framework)
local Server = Canary.GetFrameworkServer()
local Controller = Server.CreateNetworkController("Test")

Controller:Listen(function(sender: Player, ...: unknown)
    print(sender, ...)
end)
