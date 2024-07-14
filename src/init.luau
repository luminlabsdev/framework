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
local NetworkRoot = {
	Event = function(name: string, reliable: boolean?)
		return Network.Interface.new("Event", name, reliable)
	end,
	Function = function(name: string, reliable: boolean?)
		return Network.Interface.new("Function", name, reliable)
	end,
}

-- Functions

-- Fetches the server interface
local function GetServer(): Types.Server
	assert(RunService:IsServer(), "[Lumin] Cannot get server interfaces on client")
	return Server
end

-- Fetches the client interface
local function GetClient(): Types.Client
	assert(RunService:IsClient(), "[Lumin] Cannot get client interfaces on server")

	local Player = PlayerService.LocalPlayer

	Client.PlayerGui = Player:WaitForChild("PlayerGui") :: PlayerGui
	Client.Player = Player :: Player

	return Client
end

-- Loads any module that is within the provided parent, and then filtered if a function is given
-- Please note that these modules could load in any order, and that
local function Load(container: Instance, filter: ((module: ModuleScript) -> boolean)?)
	task.defer(function()
		local Imported = {}
		for _, module in container:GetChildren() do
			if not module:IsA("ModuleScript") then
				continue
			end
			if not filter or (filter and filter(module)) then
				local ImportedModule = (require)(module)
				table.insert(Imported, ImportedModule)
			end
		end
		for _, module in Imported do
			if module["Init"] and type(module.Init) == "function" then
				module.Init()
			end
		end
		table.clear(Imported)
	end)
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

Client.Network = NetworkRoot
Server.Network = NetworkRoot

export type Character15Joint = Types.Character15Joint
export type Character6Joint = Types.Character6Joint
export type Promise = Types.Promise<any>
export type ServerFunction = Types.ServerFunction
export type ServerEvent = Types.ServerEvent
export type ClientFunction = Types.ClientFunction
export type ClientEvent = Types.ClientEvent

return {
	Promise = Promise :: Types.PromiseLib,

	Server = GetServer,
	Client = GetClient,
	Load = Load,
	Signal = GetSignal,
	Event = GetSignal,
}
