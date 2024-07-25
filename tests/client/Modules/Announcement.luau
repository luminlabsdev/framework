local Lumin = require(game.ReplicatedStorage.Packages.Framework)
local Client = Lumin.Client()

local function Init()
    local Gui = Client.PlayerGui:WaitForChild("Announce")
    local Label = Gui:WaitForChild("AnnounceLabel") :: TextLabel

    Client.Network.Event("Announcer"):andThen(function(event)
        event:Listen(function(message)
            Label.Text = message
            task.wait(5)
            Label.Text = ""
        end)
    end)
end

return {
    Init = Init
}