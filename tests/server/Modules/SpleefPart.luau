local Lumin = require(game.ReplicatedStorage.Packages.Framework)
local GameFinishSignal = Lumin.Signal()

local CollectionService = game:GetService("CollectionService")
local SpleefBricks = CollectionService:GetTagged("SpleefBrick")

local InitialBrickCount = #SpleefBricks
local BrokenBricks = 0
local TouchDebounce = false

local function Init()
	for _, part: Part in SpleefBricks do
		part.Touched:Connect(function(basePart)
			if not part.CanCollide or TouchDebounce then
				return
			end

			TouchDebounce = true

			local Character = basePart.Parent :: Model

			if Character:FindFirstChildWhichIsA("Humanoid") then
				task.wait(0.2)
				print("Broke part")

				part.Transparency = 1
				part.CanCollide = false

				BrokenBricks += 1

				if BrokenBricks == InitialBrickCount then
					GameFinishSignal:Fire()
				end
			end

			TouchDebounce = false
		end)
	end

	GameFinishSignal:Connect(function()
		print("Game finished!")
		task.wait(3)
		for _, part: Part in SpleefBricks do
			part.Transparency = 0
			part.CanCollide = true
		end
		BrokenBricks = 0
	end)
end

return {
	Init = Init
}