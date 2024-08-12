local Lumin = require(game.ReplicatedStorage.Packages.framework)

local CollectionService = game:GetService("CollectionService")
local SpleefBricks = CollectionService:GetTagged("SpleefBrick")

local InitialBrickCount = #SpleefBricks
local BrokenBricks = 0
local TouchDebounce = false

local SpleefPart = {}

function SpleefPart.Init()
	SpleefPart.GameFinishedSignal = Lumin.Signal()
	SpleefPart.GameFinishedSignal:Connect(function()
		print("Game finished!")
		task.wait(3)
		for _, part: Part in SpleefBricks do
			part.Transparency = 0
			part.CanCollide = true
		end
		BrokenBricks = 0
	end)
end

function SpleefPart.Start()
	for _, part: Part in SpleefBricks do
		part.Touched:Connect(function(basePart)
			if not part.CanCollide or TouchDebounce then
				return
			end

			TouchDebounce = true

			local Character = basePart.Parent :: Model

			if Character:FindFirstChildWhichIsA("Humanoid") then
				task.wait(0.15)
				print("Broke part")

				part.Transparency = 1
				part.CanCollide = false

				BrokenBricks += 1

				if BrokenBricks == InitialBrickCount then
					SpleefPart.GameFinishedSignal:Fire()
				end
			end

			TouchDebounce = false
		end)
	end
end

return Lumin.Controller("SpleefPart", SpleefPart)