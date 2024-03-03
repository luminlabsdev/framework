local Canary = require(game.ReplicatedStorage.Packages.Framework)
local Client = Canary.Client()

local AnnounceNetwork = Client.Network.Event("Announcer")
local Gui = Client.PlayerGui:WaitForChild("Announce")
local Label = Gui:WaitForChild("AnnounceLabel")

AnnounceNetwork:Listen(function(message)
    Label.Text = message
    task.wait(5)
    Label.Text = ""
end)