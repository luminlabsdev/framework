local RunService = game:GetService("RunService")
local Canary = require(game.ReplicatedStorage.Packages.Framework)
local Client = Canary.GetFrameworkClient()
local Controller = Client.CreateNetworkController("Test")

RunService.Heartbeat:Connect(function()
    Controller:Fire(Vector3.zero)
end)