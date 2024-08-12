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

local count = 0

function Announcement.Start()
	Lumin.Worker("PostSimulation", function()
		if count == 120 then
			count = 0
		end
		count += 1
		print(count)
	end)

	AnnouncerEvent:Listen(function(message)
		Announcement.Label.Text = message
		task.wait(5)
		Announcement.Label.Text = ""
	end)
end

return Lumin.Controller("Announcement", Announcement)
