-- Module

local Root = {}
local Server = {}
local Client = {}

-- Variables

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Network = require(script.Network)
local Signal = require(script.Parent.signal)
local Types = require(script.Types)
local Objects = require(script.Objects)

local NetworkRoot = table.freeze({
	Event = function(name: string, reliable: boolean?)
		return Network.new("Event", name, reliable)
	end,
	Function = function(name: string, reliable: boolean?)
		return Network.new("Function", name, reliable)
	end,
})

-- Functions

function Root.Server()
	assert(RunService:IsServer(), "Cannot get server interfaces on client")
	return Server
end

function Root.Client()
	assert(RunService:IsClient(), "Cannot get client interfaces on server")

	local Player = PlayerService.LocalPlayer

	if not Player.Character then
		Player.CharacterAdded:Wait()
	end

	Client.PlayerGui = Player:WaitForChild("PlayerGui") :: PlayerGui
	Client.Player = Player :: Player

	return Client
end

function Root.Load(parent: Instance, filter: (module: ModuleScript) -> boolean?)
	for _, module in parent:GetChildren() do
		if not module:IsA("ModuleScript") then
			continue
		end
		if filter and filter(module) then
			local imported = (require)(module)
			if type(imported["Init"]) == "function" then
				imported["Init"]()
			end
		end
	end
end

function Root.Signal(name: string?)
	if not name then
		return Signal.new()
	end

	if not Objects.Signals[name] then
		local NewSignal = Signal.new()
		Objects.Signals[name] = NewSignal
	end

	return Objects.Signals[name]
end

function Client.Character(): Types.Character6Joint
	local Player = PlayerService.LocalPlayer
	return Player.Character or Player.CharacterAdded:Wait()
end

Client.Network = NetworkRoot :: Types.NetworkRoot<Types.ClientEvent, Types.ClientFunction>
Server.Network = NetworkRoot :: Types.NetworkRoot<Types.ServerEvent, Types.ServerFunction>

return table.freeze(Root)
