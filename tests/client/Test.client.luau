local Canary = require(game.ReplicatedStorage.Packages.Framework)
local Client = Canary.GetFrameworkClient()

local AnnounceNetwork = Client.NetworkController("Announcer")
local Gui: ScreenGui = Client.PlayerGui:WaitForChild("Announce")
local Label = Gui:WaitForChild("AnnounceLabel") :: TextLabel

AnnounceNetwork:Listen(function(message)
    Label.Text = message
    task.wait(5)
    Label.Text = ""
end)
task.wait(10)
print(AnnounceNetwork:InvokeAsync("..dss"):Await())
