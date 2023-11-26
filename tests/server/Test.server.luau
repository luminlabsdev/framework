local Canary = require(game.ReplicatedStorage.Packages.Framework)
local Server = Canary.GetFrameworkServer()
local Controller = Server.NetworkController("Test")
local Controller2 = Server.NetworkController("Other")

Controller:Listen(function(sender: Player, ...: unknown)
    print(sender, ...)
end)

Controller2:BindToInvocation(function(sender, data)
    return `{data} from {sender.Name}!`
end)
