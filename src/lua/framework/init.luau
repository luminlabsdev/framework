-- // Packages

local CanaryEngine = { }

local CanaryEngineServer = { }
local CanaryEngineClient = { }
local CanaryEngineShared = { }

local Libraries = script.Libraries

-- // Variables

local PlayerService = game:GetService("Players")
local BeginLoadTime = os.clock()

local Types = require(script.Types) -- The types used for all libraries inside of the framework

local Network = require(script.Network) -- Networking logic
local Signal = require(Libraries.Red.Signal) -- Signal logic

local Future = require(Libraries.Red.Future) -- Promise logic
local Guard = require(Libraries.Red.Guard) -- Runtime typechecking
local Debugger = require(script.Debugger) -- Easy debug logic
local Runtime = require(script.Runtime) -- Runtime settings + debugger

CanaryEngine.Runtime = table.freeze({
	Settings = Runtime.Settings,
	Context = Runtime.Context,
	Objects = Runtime.Objects,
})

CanaryEngine.Debugger = Debugger
CanaryEngine.Future = Future
CanaryEngine.Guard = Guard

local RuntimeObjects = CanaryEngine.Runtime.Objects

-- // Functions

local function CreateNetworkController(controllerName: string): Network.Client<...any> | Network.Server<...any>
	Debugger.LogEvent(script, "Create NetworkController", true)

	if not RuntimeObjects.NetworkControllers[controllerName] then
		local NewNetworkController = Network(controllerName)

		RuntimeObjects.NetworkControllers[controllerName] = NewNetworkController
	end
	
	return RuntimeObjects.NetworkControllers[controllerName]
end

-- Engine Contexts

function CanaryEngine.GetFrameworkServer()
	if Runtime.Context.Server then
		if table.isfrozen(CanaryEngineServer) then
			return CanaryEngineServer
		end

		CanaryEngineServer.Data = require(Libraries.EasyProfile)
		return table.freeze(CanaryEngineServer)
	else
		error("Failed to fetch 'EngineServer', context must be server.")
	end
end

function CanaryEngine.GetFrameworkClient()
	if Runtime.Context.Client then
		if table.isfrozen(CanaryEngineClient) then
			return CanaryEngineClient
		end

		local Player = PlayerService.LocalPlayer

		CanaryEngineClient.Player = Player :: Player
		CanaryEngineClient.PlayerGui = Player:WaitForChild("PlayerGui") :: typeof(game:GetService("StarterGui"))
		CanaryEngineClient.PlayerBackpack = Player:WaitForChild("Backpack") :: typeof(game:GetService("StarterPack"))

		return table.freeze(CanaryEngineClient)
	else
		error("Failed to fetch 'EngineClient', context must be client.")
	end
end

-- Exclusive API for shared will come soon
function CanaryEngine.GetFrameworkShared()
	if table.isfrozen(CanaryEngineShared) then
		return CanaryEngineShared
	end

	return table.freeze(CanaryEngineShared)
end

function CanaryEngine.ImportPackagesInOrder(importList: {ModuleScript}, importDeep: boolean?)
	for _, package in importList do
		require(package)
		
		if importDeep then
			for _, deepPackage in package:GetDescendants() do
				if deepPackage:IsA("ModuleScript") then
					require(deepPackage)
				end
			end
		end
	end
end

-- Signal Creation

function CanaryEngine.CreateSignal(signalName: string?): Signal.Signal<...any>
	Debugger.LogEvent(script, "Create SignalController", true)

	if not signalName then
		return Signal()
	end

	if not RuntimeObjects.Signals[signalName] then
		local NewSignal = Signal()

		RuntimeObjects.Signals[signalName] = NewSignal
	end

	return RuntimeObjects.Signals[signalName]
end

function CanaryEngine.CreateAnonymousSignal(): Signal.Signal<...any>
	return CanaryEngine.CreateSignal()
end

-- Context Specific Functions

function CanaryEngineClient.GetPlayerCharacter(): Types.Character
	local Player = PlayerService.LocalPlayer
	return Player.Character or Player.CharacterAdded:Wait()
end

CanaryEngineClient.CreateNetworkController = CreateNetworkController :: (controllerName: string) -> (Network.Client<...any>)
CanaryEngineServer.CreateNetworkController = CreateNetworkController :: (controllerName: string) -> (Network.Server<...any>)
CanaryEngine.GetFrameworkReplicated = CanaryEngine.GetFrameworkShared

-- // Actions

Debugger.LogEvent(script, `Framework loaded; {(os.clock() - BeginLoadTime) * 1000}ms`)

return table.freeze(CanaryEngine)