local Lumin = require(game.ReplicatedStorage.Packages.Framework)
local Server = Lumin.Server()

local AnnounceNetwork = Server.Network.Event("Announcer"):expect()

local CollectionService = game:GetService("CollectionService")
local PlayerService = game:GetService("Players")

local KillBricks = CollectionService:GetTagged("KillBrick")
local KillDebounce = false

local function Init()
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

return {
	Init = Init,
}
