local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = PlayerService.LocalPlayer

local Lumin = require(ReplicatedStorage.Packages.framework)
local Net = require(ReplicatedStorage.DevPackages.net).Client

local Announcement = {}
local AnnouncerEvent = Net.Event("Announcer")

function Announcement.Init()
	Announcement.Gui = Player.PlayerGui:WaitForChild("Announce")
	Announcement.Label = Announcement.Gui:WaitForChild("AnnounceLabel")
end

function Announcement.Start()
	AnnouncerEvent:Listen(function(message)
		Announcement.Label.Text = message
		task.wait(5)
		Announcement.Label.Text = ""
	end)
end

return Lumin.New(Announcement)
