--!strict

-- // Packages

local CanaryEngine = { }

local FrameworkServer = { }
local FrameworkClient = { }
local FrameworkShared = { }

local Packages = script.Parent

-- // Types

export type Character = {
	["Body Colors"]: BodyColors,
	HumanoidRootPart: Part,
	Humanoid: Humanoid & {
		HumanoidDescription: HumanoidDescription,
		Animator: Animator,
	},
	Head: Part & {
		face: Decal,
		Mesh: SpecialMesh,
	},
	["Left Arm"]: Part,
	["Left Leg"]: Part,
	["Right Arm"]: Part,
	["Right Leg"]: Part,
	["Torso"]: Part & {
		roblox: Decal
	}
} & Model

-- // Variables

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local BeginLoadTime = os.clock()

local Network = require(script.Network) -- Networking logic
local Signal = require(Packages.signal) -- Signal logic

local Future = require(Packages.future) -- Promise logic
local Debugger = require(script.Debugger) -- Easy debug logic
local Runtime = require(script.Runtime) -- Runtime settings + debugger

CanaryEngine.Runtime = table.freeze({
	Settings = Runtime.Settings,
	Context = Runtime.Context,
	Objects = Runtime.Objects,
})

CanaryEngine.Debugger = Debugger
CanaryEngine.Future = Future

local RuntimeObjects = CanaryEngine.Runtime.Objects
local RunContext = if RunService:IsServer() then "server" else "client"

-- // Functions

local function NetworkController(controllerName: string): Network.Client<...any> | Network.Server<...any>
	if not RuntimeObjects.NetworkControllers[controllerName] then
		local NewNetworkController = Network(controllerName)
		Debugger.LogEvent(`Create NetworkController {controllerName}`)

		RuntimeObjects.NetworkControllers[controllerName] = NewNetworkController
	end
	
	return RuntimeObjects.NetworkControllers[controllerName]
end

-- Engine Contexts

function CanaryEngine.GetFrameworkServer()
	if Runtime.Context.Server then
		if table.isfrozen(FrameworkServer) then
			return FrameworkServer
		end

		return table.freeze(FrameworkServer)
	else
		error("Failed to fetch 'EngineServer', context must be server.")
	end
end

function CanaryEngine.GetFrameworkClient()
	if Runtime.Context.Client then
		if table.isfrozen(FrameworkClient) then
			return FrameworkClient
		end

		local Player = PlayerService.LocalPlayer

		FrameworkClient.Player = Player :: Player
		FrameworkClient.PlayerGui = Player:WaitForChild("PlayerGui") :: typeof(game:GetService("StarterGui"))
		FrameworkClient.PlayerBackpack = Player:WaitForChild("Backpack") :: typeof(game:GetService("StarterPack"))

		return table.freeze(FrameworkClient)
	else
		error("Failed to fetch 'EngineClient', context must be client.")
	end
end

-- Exclusive API for shared will come soon
function CanaryEngine.GetFrameworkShared()
	if table.isfrozen(FrameworkShared) then
		return FrameworkShared
	end

	return table.freeze(FrameworkShared)
end

function CanaryEngine.ImportPackagesInOrder(importList: {ModuleScript}, importDeep: boolean?)
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

-- Signal Creation

function CanaryEngine.Signal(signalName: string?): Signal.Signal<...any>
	if not signalName then
		Debugger.LogEvent(`Create Signal {signalName}`)
		return Signal()
	end

	if not RuntimeObjects.Signals[signalName] then
		local NewSignal = Signal()
		Debugger.LogEvent(`Create Signal {signalName}`)

		RuntimeObjects.Signals[signalName] = NewSignal
	end
	
	return RuntimeObjects.Signals[signalName]
end

function CanaryEngine.CreateAnonymousSignal(): Signal.Signal<...any>
	return CanaryEngine.Signal()
end

-- Context Specific Functions

function FrameworkClient.GetPlayerCharacter(): Character
	local Player = PlayerService.LocalPlayer
	return Player.Character or Player.CharacterAdded:Wait()
end

FrameworkClient.NetworkController = NetworkController :: (controllerName: string) -> (Network.Client<...any>)
FrameworkServer.NetworkController = NetworkController :: (controllerName: string) -> (Network.Server<...any>)

-- Aliases
CanaryEngine.GetFrameworkReplicated = CanaryEngine.GetFrameworkShared

-- // Actions

Debugger.LogEvent(`Framework {RunContext} loaded; {math.ceil((os.clock() - BeginLoadTime) * 1000)}ms`)

return table.freeze(CanaryEngine)