-- Module

local Root = {}
local Server = {}
local Client = {}

-- Variables

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Types = require(script.Types)
local Network = require(script.Network)
local Signal = require(script.Parent.signal)
local Promise = require(script.Parent.promise)
local Objects = require(script.Objects)

local NetworkRoot = table.freeze({
	Event = function(name: string, reliable: boolean?)
		return Network.Interface.new("Event", name, reliable)
	end,
	Function = function(name: string, reliable: boolean?)
		return Network.Interface.new("Function", name, reliable)
	end,
})

Root.Promise = Promise :: Types.PromiseLib

-- Functions

function Root.Server()
	assert(RunService:IsServer(), "[Lumin] Cannot get server interfaces on client")
	return Server
end

function Root.Client()
	assert(RunService:IsClient(), "[Lumin] Cannot get client interfaces on server")

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

function Root.Signal(name: string?): Signal.Signal<any>
	if not name then
		return Signal.new()
	end

	if not Objects.Signals[name] then
		local NewSignal = Signal.new()
		Objects.Signals[name] = NewSignal
	end

	return Objects.Signals[name]
end

function Client.Character(): Types.Promise<Types.Character6Joint>
	return Promise.new(function(resolve)
		local Player = PlayerService.LocalPlayer
		resolve(Player.Character or Player.CharacterAdded:Wait())
	end)
end

Root.Event = Root.Signal

Client.Network = NetworkRoot :: Types.NetworkRoot<Types.ClientEvent, Types.ClientFunction>
Server.Network = NetworkRoot :: Types.NetworkRoot<Types.ServerEvent, Types.ServerFunction>

return table.freeze(Root)
