-- // Package

local CanaryEngine = { }

local FrameworkServer = { }
local FrameworkClient = { }
local FrameworkShared = { }

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
local Signal = require(script.Parent.signal) -- Signal logic

local Future = require(script.Parent.future) -- Promise logic
local Debugger = require(script.Debugger) -- Easy debug logic
local Runtime = require(script.Runtime) -- Runtime settings

CanaryEngine.Runtime = table.freeze({
	Settings = Runtime.Settings,
	Context = Runtime.Context,
	Objects = Runtime.Objects,
})

CanaryEngine.Debugger = Debugger
CanaryEngine.Future = Future

local RuntimeObjects = CanaryEngine.Runtime.Objects
local RunContext = if RunService:IsServer() then "Server" else "Client"

-- // Functions

local function PrecisionRound(num: number, pos: number)
	local precision = 10^(-pos)
	num += precision / 2
	return math.floor(num / precision) * precision
end

local function NetworkController(controllerName: string): Network.Client<...any> | Network.Server<...any>
	if not RuntimeObjects.NetworkControllers[controllerName] then
		local NewNetworkController = Network(controllerName)
		Debugger.LogEvent(`[{RunContext}] Create NetworkController {controllerName}`)

		RuntimeObjects.NetworkControllers[controllerName] = NewNetworkController
	end
	
	return RuntimeObjects.NetworkControllers[controllerName]
end

-- Engine Contexts

function CanaryEngine.GetFrameworkServer()
	assert(Runtime.Context.Server, "Cannot get server interfaces on client")
	
	if table.isfrozen(FrameworkServer) then
		return FrameworkServer
	end

	return table.freeze(FrameworkServer)
end

function CanaryEngine.GetFrameworkClient()
	assert(Runtime.Context.Client, "Cannot get client interfaces on server")

	if table.isfrozen(FrameworkClient) then
		return FrameworkClient
	end

	local Player = PlayerService.LocalPlayer

	FrameworkClient.Player = Player :: Player
	FrameworkClient.PlayerGui = Player:WaitForChild("PlayerGui") :: typeof(game:GetService("StarterGui"))
	FrameworkClient.PlayerBackpack = Player:WaitForChild("Backpack") :: typeof(game:GetService("StarterPack"))

	return table.freeze(FrameworkClient)
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
		Debugger.LogEvent(`[Framework] Create Signal {signalName}`)
		return Signal()
	end

	if not RuntimeObjects.Signals[signalName] then
		local NewSignal = Signal()
		Debugger.LogEvent(`[Framework] Create Signal {signalName}`)

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

-- // Actions

CanaryEngine.LoadTime = PrecisionRound(os.clock() - BeginLoadTime, 2)
Debugger.LogEvent(`[Framework] {RunContext} loaded; {CanaryEngine.LoadTime}s ({CanaryEngine.LoadTime * 1000}ms)`)

return table.freeze(CanaryEngine)