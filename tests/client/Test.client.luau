local RunService = game:GetService("RunService")
local Canary = require(game.ReplicatedStorage.Packages.Framework)
local Client = Canary.GetFrameworkClient()
local Controller = Client.NetworkController("Test")

RunService.Heartbeat:Connect(function()
    Controller:Fire(Vector3.zero)
    Canary.Debugger.LogEvent(script, "Example!")
end)