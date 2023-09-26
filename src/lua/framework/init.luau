-- // Packages

local CanaryEngine = { }

local CanaryEngineServer = { }
local CanaryEngineClient = { }
local CanaryEngineReplicated = { }

-- // Variables

local PlayerService = game:GetService("Players")

local EngineVendor = script.Parent.Vendor
local EngineLibraries = EngineVendor.Libraries

local Types = require(EngineVendor.Types) -- The types used for all libraries inside of the framework
local Controllers = require(EngineVendor.Controllers.Init)
local Network = Controllers.NetworkController -- Networking logic
local Signal = Controllers.SignalController -- Signal logic

local Future = require(EngineLibraries.RedbloxUtils.Future) -- Promise logic
local Debugger = require(EngineVendor.Debugger) -- Easy debug logic
local Runtime = require(EngineVendor.Runtime) -- Runtime settings + debugger

local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

CanaryEngine.Runtime = table.freeze({
	RuntimeSettings = RuntimeSettings,
	RuntimeContext = RuntimeContext,
	RuntimeObjects = {
		NetworkControllers = { },
		SignalControllers = { },
	},
})

CanaryEngine.Debugger = Debugger
CanaryEngine.Future = Future

local RuntimeObjects = CanaryEngine.Runtime.RuntimeObjects

-- // Functions

local function CreateNetworkController(controllerName: string): Types.ClientNetworkController<any, any> | Types.ServerNetworkController<any, any>
	if not RuntimeObjects.NetworkControllers[controllerName] then
		local NewNetworkController = Network.CreateController(controllerName)

		RuntimeObjects.NetworkControllers[controllerName] = NewNetworkController
	end
	
	return RuntimeObjects.NetworkControllers[controllerName]
end

-- Engine Contexts

function CanaryEngine.GetEngineServer()
	if RuntimeContext.Server then
		CanaryEngineServer.Data = require(EngineVendor.Libraries.EasyProfile.Init)
		return table.freeze(CanaryEngineServer)
	else
		Debugger.Debug(error, "Failed to fetch 'EngineServer', context must be server.", nil, false)
		return
	end
end

function CanaryEngine.GetEngineClient()
	if RuntimeContext.Client then
		local Player = PlayerService.LocalPlayer

		CanaryEngineClient.Player = Player :: Player
		CanaryEngineClient.PlayerGui = Player:WaitForChild("PlayerGui") :: typeof(game:GetService("StarterGui"))
		CanaryEngineClient.PlayerBackpack = Player:WaitForChild("Backpack") :: typeof(game:GetService("StarterPack"))

		return table.freeze(CanaryEngineClient)
	else
		Debugger.Debug(error, "Failed to fetch 'EngineClient', context must be client.", nil, false)
		return
	end
end

-- Exclusive API for replicated will come soon
function CanaryEngine.GetEngineReplicated()
	return table.freeze(CanaryEngineReplicated)
end

-- Signal Creation

function CanaryEngine.CreateSignal(signalName: string?): Types.SignalController<any>
	if not signalName then
		return Signal.CreateController("Anonymous")
	end

	if not RuntimeObjects.SignalControllers[signalName] then
		local NewSignal = Signal.CreateController(signalName)

		RuntimeObjects.SignalControllers[signalName] = NewSignal
	end

	return RuntimeObjects.SignalControllers[signalName]
end

function CanaryEngine.CreateAnonymousSignal(): Types.SignalController<any>
	return CanaryEngine.CreateSignal()
end

-- Context Specific Functions

function CanaryEngineClient.GetPlayerCharacter(): Types.Character
	return PlayerService.LocalPlayer.Character or PlayerService.LocalPlayer.CharacterAdded:Wait()
end

CanaryEngineClient.CreateNetworkController = CreateNetworkController :: (controllerName: string) -> (Types.ClientNetworkController<any, any>)
CanaryEngineServer.CreateNetworkController = CreateNetworkController :: (controllerName: string) -> (Types.ServerNetworkController<any, any>)

-- // Actions

return table.freeze(CanaryEngine)