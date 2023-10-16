-- // Packages

local CanaryEngine = { }

local CanaryEngineServer = { }
local CanaryEngineClient = { }
local CanaryEngineReplicated = { }

-- // Variables

local PlayerService = game:GetService("Players")
local BeginLoadTime = os.clock()

local EngineVendor = script.Parent.Vendor
local EngineLibraries = EngineVendor.Libraries

local Types = require(EngineVendor.Types) -- The types used for all libraries inside of the framework
local Network = require(EngineVendor.Network.Init) -- Networking logic
local Signal = require(EngineLibraries.RedbloxUtils.Signal) -- Signal logic

local Future = require(EngineLibraries.RedbloxUtils.Future) -- Promise logic
local Guard = require(EngineLibraries.RedbloxUtils.Guard) -- Runtime typechecking
local Debugger = require(EngineVendor.Debugger) -- Easy debug logic
local Runtime = require(EngineVendor.Runtime) -- Runtime settings + debugger

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
	Debugger.LogEvent(script, "Create NetworkController", false, true)

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

		CanaryEngineServer.Data = require(EngineVendor.Libraries.EasyProfile.Init)
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

-- Exclusive API for replicated will come soon
function CanaryEngine.GetFrameworkReplicated()
	if table.isfrozen(CanaryEngineReplicated) then
		return CanaryEngineReplicated
	end

	return table.freeze(CanaryEngineReplicated)
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
	Debugger.LogEvent(script, "Create SignalController", false, true)

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

-- // Actions

Debugger.LogEvent(script, `Framework loaded`, false, true)
Debugger.Debug(print, `Framework loaded in {os.clock() - BeginLoadTime} seconds`)

return table.freeze(CanaryEngine)