local Canary = require(game.ReplicatedStorage.Packages.Framework)
local Benchmark = require(game.ReplicatedStorage.DevPackages.benchmark)
local Client = Canary.GetFrameworkClient()
local Controller = Client.NetworkController("Test")
local Controller2 = Client.NetworkController("Other")

Controller:Fire(Vector3.zero)

print(Controller2:InvokeAsync("yoooooo"):Await())

local result = Benchmark.CreateBenchmark():SetFunction(1000, function()
    Canary.Debugger.LogEvent("Hello Test!!!")
end)

print(result)