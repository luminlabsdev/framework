-- // Package

local Root = {}
local FrameworkServer = {}
local FrameworkClient = {}

-- // Variables

local BeginLoadTime = os.clock()

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local Network = require(script.Network) -- Networking logic
local Event = require(script.Parent.event) -- Event logic

local Debugger = require(script.Debugger) -- Easy debug logic
local Runtime = require(script.Runtime) -- Runtime settings
local Types = require(script.Types)

Root.Runtime = Runtime
Root.Debugger = Debugger

local RuntimeObjects = Root.Runtime.Objects
local RunContext = if RunService:IsServer() then "Server" else "Client"

local NetworkRoot = {
	Event = function(name: string, reliable: boolean?)
		return Network("Event", name, reliable)
	end,
	Function = function(name: string, reliable: boolean?)
		return Network("Function", name, reliable)
	end
}

-- // Functions

-- Engine Contexts

function Root.GetFrameworkServer()
	assert(RunService:IsServer(), "Cannot get server interfaces on client")
	
	if table.isfrozen(FrameworkServer) then
		return FrameworkServer
	end

	return table.freeze(FrameworkServer)
end

function Root.GetFrameworkClient()
	assert(RunService:IsClient(), "Cannot get client interfaces on server")

	local Player = PlayerService.LocalPlayer

	Player.CharacterAdded:Connect(function() -- when the player respawns the old player gui/backpack are removed
		FrameworkClient.PlayerGui = Player:WaitForChild("PlayerGui")
		FrameworkClient.PlayerBackpack = Player:WaitForChild("Backpack") 
	end)

	FrameworkClient.Player = Player :: Player
	FrameworkClient.PlayerGui = Player:WaitForChild("PlayerGui") :: typeof(game:GetService("StarterGui"))
	FrameworkClient.PlayerBackpack = Player:WaitForChild("Backpack") :: typeof(game:GetService("StarterPack"))
	
	return FrameworkClient
end

function Root.ImportPackagesOrdered(importList: {ModuleScript}, importDeep: boolean?)
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

-- Event Creation

function Root.Event(eventName: string?): Event.Signal<...any>
	if not eventName then
		Debugger.LogEvent("[Framework] Create Event Anonymous")
		return Event()
	end

	if not RuntimeObjects.Signals[eventName] then
		local NewSignal = Event()
		Debugger.LogEvent(`[Framework] Create Event {eventName}`)

		RuntimeObjects.Signals[eventName] = NewSignal
	end

	return RuntimeObjects.Signals[eventName]
end

function Root.Signal(signalName: string?): Event.Signal<...any>
	return Root.Event(signalName)
end

-- Context Specific Functions

function FrameworkClient.GetPlayerCharacter(): Types.Character6Joint
	local Player = PlayerService.LocalPlayer
	return Player.Character or Player.CharacterAdded:Wait()
end

FrameworkClient.Network = NetworkRoot :: {Event: (name: string, reliable: boolean?) -> (Network.ClientEvent), Function: (name: string, reliable: boolean?) -> (Network.ClientFunction)}
FrameworkServer.Network = NetworkRoot :: {Event: (name: string, reliable: boolean?) -> (Network.ServerEvent), Function: (name: string, reliable: boolean?) -> (Network.ServerFunction)}

-- // Actions

Root.LoadTime = tonumber(string.format("%.2f", (os.clock() - BeginLoadTime) * 1000)) :: number
Debugger.LogEvent(`[Framework] {RunContext} loaded; {Root.LoadTime}ms`)

return table.freeze(Root)