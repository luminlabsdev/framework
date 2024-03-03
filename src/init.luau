-- // Package

local Root = {}
local Server = {}
local Client = {}

-- // Variables

local BeginLoadTime = os.clock()

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Network = require(script.Network) -- Networking logic
local Event = require(script.Parent.event) -- Event logic

local Debugger = require(script.Debugger) -- Easy debug logic
local Runtime = require(script.Runtime) -- Runtime settings
local Types = require(script.Types) -- Package types

Root.Runtime = Runtime
Root.Debugger = Debugger

local RuntimeObjects = Root.Runtime.Objects
local RunContext = if RunService:IsServer() then "Server" else "Client"

local NetworkRoot = table.freeze({
	Event = function(name: string, reliable: boolean?)
		return Network("Event", name, reliable)
	end,
	Function = function(name: string, reliable: boolean?)
		return Network("Function", name, reliable)
	end,
})

-- // Functions

function Root.Server()
	assert(RunService:IsServer(), "Cannot get server interfaces on client")

	if table.isfrozen(Server) then
		return Server
	end

	return table.freeze(Server)
end

function Root.Client()
	assert(RunService:IsClient(), "Cannot get client interfaces on server")

	if table.isfrozen(Client) then
		return Client
	end

	local Player = PlayerService.LocalPlayer
	Client.Player = Player :: Player

	if not Player.Character then
		Player.CharacterAdded:Wait()
	end

	Client.PlayerGui = Player:WaitForChild("PlayerGui") :: typeof(game:GetService("StarterGui"))
	Client.PlayerBackpack = Player:WaitForChild("Backpack") :: typeof(game:GetService("StarterPack"))

	return table.freeze(Client)
end

function Root.ImportPackages(importList: { ModuleScript }, importDeep: boolean?)
	for _, package in importList do
		(require)(package)

		if importDeep then
			for _, deepPackage in package:GetDescendants() do
				if deepPackage:IsA("ModuleScript") then
					(require)(deepPackage)
				end
			end
		end
	end
end

function Root.Event(eventName: string?): Event.Signal<...any>
	if not eventName then
		Debugger.LogEvent("[%s] Create Event Anonymous", RunContext)
		return Event()
	end

	if not RuntimeObjects.Events[eventName] then
		local NewSignal = Event()
		Debugger.LogEvent("[%s] Create Event %s", RunContext, eventName)

		RuntimeObjects.Events[eventName] = NewSignal
	end

	return RuntimeObjects.Events[eventName]
end

function Root.Signal(signalName: string?): Event.Signal<...any>
	return Root.Event(signalName)
end

function Client.GetCharacter(): Types.Character6Joint
	local Player = PlayerService.LocalPlayer
	return Player.Character or Player.CharacterAdded:Wait()
end

Client.Network = NetworkRoot :: {
	Event: (name: string, reliable: boolean?) -> Network.ClientEvent,
	Function: (name: string, reliable: boolean?) -> Network.ClientFunction,
}
Server.Network = NetworkRoot :: {
	Event: (name: string, reliable: boolean?) -> Network.ServerEvent,
	Function: (name: string, reliable: boolean?) -> Network.ServerFunction,
}

-- // Actions

Root.LoadTime = (os.clock() - BeginLoadTime) * 1000
Debugger.LogEvent("[Framework] %s Loaded; %.2fms", RunContext, Root.LoadTime)

return table.freeze(Root)
