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

local ClientStarted = false
local ServerStarted = false

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
local function GetServer(callback: ((object: Types.Server<any>) -> ())?): Types.Server<any>
	assert(RunService:IsServer(), "[Lumin] Cannot get server interfaces on client")

	if not ServerStarted then
        ServerStarted = true
		if callback then
			callback(Server)
		end
	end

	return Server
end

-- Fetches the client interface
local function GetClient(callback: ((object: Types.Client<any>) -> ())?): Types.Client<any>
	assert(RunService:IsClient(), "[Lumin] Cannot get client interfaces on server")

	if not ClientStarted then
		local Player = PlayerService.LocalPlayer
        ClientStarted = true

		Client.PlayerGui = Player:WaitForChild("PlayerGui") :: PlayerGui
		Client.Player = Player :: Player
        Client.Camera = workspace.CurrentCamera

		if callback then
			callback(Client)
		end
	end

	return Client
end

-- Loads any module that is within the provided parent, and then filtered if a function is given
-- Please note that these modules could load in any order, and that
local function Load(container: Instance, filter: ((module: ModuleScript) -> boolean)?)
	task.defer(function()
		local Imported = {}
		for _, module in container:GetChildren() do
			if module:IsA("ModuleScript") then
                if not filter or (filter and filter(module)) then
                    local ImportedModule = (require)(module)
                    table.insert(Imported, ImportedModule)
                end
			end
		end
		for _, module in Imported do
			if module.Init and type(module.Init) == "function" then
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
local function Character(): Types.Promise<Types.Character6Joint & Types.Character15Joint>
	return Promise.new(function(resolve)
		local Player = PlayerService.LocalPlayer
		resolve(Player.Character or Player.CharacterAdded:Wait())
	end)
end

Client.Character = Character
Client.Network = NetworkRoot
Server.Network = NetworkRoot

export type Character15Joint = Types.Character15Joint
export type Character6Joint = Types.Character6Joint
export type Promise<T...> = Types.Promise<T...>
export type ServerFunction<T..., U...> = Types.ServerFunction<T..., U...>
export type ServerEvent<T..., U...> = Types.ServerEvent<T..., U...>
export type ClientFunction<T..., U...> = Types.ClientFunction<T..., U...>
export type ClientEvent<T..., U...> = Types.ClientEvent<T..., U...>

return {
	Promise = Promise :: Types.PromiseLib,

	Server = GetServer,
	Client = GetClient,
	Load = Load,
	Signal = GetSignal,
	Event = GetSignal,
}
