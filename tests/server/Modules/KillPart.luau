local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PlayerService = game:GetService("Players")

local Lumin = require(ReplicatedStorage.Packages.framework)
local Net = require(ReplicatedStorage.DevPackages.net).Server

local AnnounceNetwork = Net.Event("Announcer")

local KillBricks = CollectionService:GetTagged("KillBrick")
local KillDebounce = false

local KillPart = {}

function KillPart.Start()
	for _, part: Part in KillBricks do
		part.Touched:Connect(function(basePart)
			if KillDebounce then
				return
			end

			KillDebounce = true

			local Character = basePart.Parent :: Model
			local PlayerCharacter = PlayerService:GetPlayerFromCharacter(Character)

			if not PlayerCharacter then
				AnnounceNetwork:FireAll("Some random guy died 💀")
			end

			AnnounceNetwork:FireAll(`{PlayerCharacter.DisplayName} died!`)

			if Character:FindFirstChildWhichIsA("Humanoid") then
				local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
				Humanoid.Health = 0
			end

			task.wait(1)

			KillDebounce = false
		end)
	end
end

return Lumin.New(KillPart)
