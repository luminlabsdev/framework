local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = PlayerService.LocalPlayer

local Lumin = require(ReplicatedStorage.Packages.framework)
local Net = require(ReplicatedStorage.DevPackages.net).Client

local Announcement = {
    UI = {}
}
local AnnouncerEvent = Net.Event("Announcer")

function Announcement.Init()
	Announcement.UI.Gui = Player.PlayerGui:WaitForChild("Announce")
	Announcement.UI.Label = Announcement.UI.Gui:WaitForChild("AnnounceLabel")
end

function Announcement.Start()
	AnnouncerEvent:Listen(function(message)
		Announcement.UI.Label.Text = message
		task.wait(5)
		Announcement.UI.Label.Text = ""
	end)
end

return Lumin.New(Announcement)
