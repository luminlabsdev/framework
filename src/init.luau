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
local BeginLoadTime = os.clock()

local Network = require(script.Network) -- Networking logic
local Signal = require(script.Parent.signal) -- Signal logic

local Future = require(script.Parent.future) -- Promise logic
local Debugger = require(script.Debugger) -- Easy debug logic
local Runtime = require(script.Runtime) -- Runtime settings

CanaryEngine.Runtime = Runtime
CanaryEngine.Debugger = Debugger
CanaryEngine.Future = Future

local RuntimeObjects = CanaryEngine.Runtime.Objects
local RunContext = if CanaryEngine.Runtime.Context.Server then "Server" else "Client"

-- // Functions

local function NetworkController(controllerName: string, isUnreliable: boolean?): Network.Client<...any> | Network.Server<...any>
	if not RuntimeObjects.NetworkControllers[controllerName] then
		local NewNetworkController = Network(controllerName, isUnreliable)
		Debugger.LogEvent(`[{RunContext}] Create {if isUnreliable then "Unreliable" else "Reliable"} NetworkController {controllerName}`)

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

	local Player = PlayerService.LocalPlayer

	Player.CharacterAdded:Connect(function() -- when the player respawns the old player gui/backpack are removed
		FrameworkClient.PlayerGui = Player:WaitForChild("PlayerGui") :: typeof(game:GetService("StarterGui"))
		FrameworkClient.PlayerBackpack = Player:WaitForChild("Backpack") :: typeof(game:GetService("StarterPack"))
	end)

	FrameworkClient.Player = Player :: Player
	
	Player.CharacterAdded:Wait()

	FrameworkClient.PlayerGui = Player:WaitForChild("PlayerGui") 
	FrameworkClient.PlayerBackpack = Player:WaitForChild("Backpack") 

	return FrameworkClient
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
		Debugger.LogEvent("[Framework] Create Signal Anonymous")
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

FrameworkClient.NetworkController = NetworkController :: (controllerName: string, isUnreliable: boolean?) -> (Network.Client<...any>)
FrameworkServer.NetworkController = NetworkController :: (controllerName: string, isUnreliable: boolean?) -> (Network.Server<...any>)

-- // Actions

CanaryEngine.LoadTime = tonumber(string.format("%.2f", (os.clock() - BeginLoadTime) * 1000)) :: number
Debugger.LogEvent(`[Framework] {RunContext} loaded; {CanaryEngine.LoadTime}ms`)

return table.freeze(CanaryEngine)