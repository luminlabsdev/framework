-- Module

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

-- Reuse NetworkRoot because it is modified internally based on RunContext
local NetworkRoot = table.freeze({
	Event = function(name: string, reliable: boolean?)
		return Network.Interface.new("Event", name, reliable)
	end,
	Function = function(name: string, reliable: boolean?)
		return Network.Interface.new("Function", name, reliable)
	end,
})

-- Functions

-- Fetches the server interface
local function GetServer()
	assert(RunService:IsServer(), "[Lumin] Cannot get server interfaces on client")
	return Server
end

-- Fetches the client interface
local function GetClient()
	assert(RunService:IsClient(), "[Lumin] Cannot get client interfaces on server")

	local Player = PlayerService.LocalPlayer

	Client.PlayerGui = Player:WaitForChild("PlayerGui") :: PlayerGui
	Client.Player = Player :: Player

	return Client
end

-- Loads any module that is within the provided parent, and then filtered if a function is given
local function Load(parent: Instance, filter: (module: ModuleScript) -> (boolean)?)
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

-- Creates a new signal, if it has no name it will remain anonymous
local function GetSignal(name: string?): Signal.Signal<any>
	if not name then
		return Signal.new()
	end

	if not Objects.Signals[name] then
		local NewSignal = Signal.new()
		Objects.Signals[name] = NewSignal
	end

	return Objects.Signals[name]
end

-- Gets the character, by either getting the current reference or waiting
function Client.Character(): Types.Promise<Types.Character6Joint>
	return Promise.new(function(resolve)
		local Player = PlayerService.LocalPlayer
		resolve(Player.Character or Player.CharacterAdded:Wait())
	end)
end

Client.Network = NetworkRoot :: Types.NetworkRoot<Types.ClientEvent, Types.ClientFunction>
Server.Network = NetworkRoot :: Types.NetworkRoot<Types.ServerEvent, Types.ServerFunction>

return {
	Promise = Promise :: Types.PromiseLib,
	
	Server = GetServer,
	Client = GetClient,
	Load = Load,
	Signal = GetSignal,
	Event = GetSignal,
}
