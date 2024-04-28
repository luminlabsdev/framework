local Lumin = require(game.ReplicatedStorage.Packages.Framework)
local Client = Lumin.Client()

local AnnounceNetwork = Client.Network.Event("Announcer"):expect()
local Gui = Client.PlayerGui:WaitForChild("Announce")
local Label = Gui:WaitForChild("AnnounceLabel")

AnnounceNetwork:Listen(function(message)
	Label.Text = message
	task.wait(5)
	Label.Text = ""
end)
