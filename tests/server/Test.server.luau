local Canary = require(game.ReplicatedStorage.Packages.Framework)
local Server = Canary.Server()

local GameFinishSignal = Canary.Event()
local AnnounceNetwork = Server.Network.Event("Announcer")

local CollectionService = game:GetService("CollectionService")
local PlayerService = game:GetService("Players")

local SpleefBricks = CollectionService:GetTagged("SpleefBrick")
local KillBricks = CollectionService:GetTagged("KillBrick")

local InitialBrickCount = #SpleefBricks
local BrokenBricks = 0

local TouchDebounce = false
local KillDebounce = false

for _, part: Part in SpleefBricks do
    part.Touched:Connect(function(basePart)
        if not part.CanCollide or TouchDebounce then
            return
        end

        TouchDebounce = true

        local Character = basePart.Parent :: Model

        if Character:FindFirstChildWhichIsA("Humanoid") then
            task.wait(0.2)
            Canary.Debugger.LogEvent("Broke part")

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

GameFinishSignal:Connect(function()
    Canary.Debugger.LogEvent("Game finished!")
    task.wait(3)
    for _, part: Part in SpleefBricks do
        part.Transparency = 0
        part.CanCollide = true
    end
    BrokenBricks = 0
end)