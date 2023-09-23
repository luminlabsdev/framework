-- // Packages

--[=[
	The parent of all classes.

	@class CanaryEngine
]=]
local CanaryEngine = { }

--[=[
	The runtime property contains settings that are set during runtime, and the current context of the server/client.

	@prop Runtime {RuntimeSettings: EngineRuntimeSettings, RuntimeContext: EngineRuntimeContext, RuntimeObjects: {NetworkControllers: {[string]: (ServerNetworkController<any, any> | ServerNetworkController<any, any>)}, SignalControllers: {[string]: SignalController<any>}}}

	@readonly
	@within CanaryEngine
]=]

--[=[
	The internal engine debugger, has useful functions to abide by debug settings.

	@prop Debugger EngineDebugger

	@readonly
	@within CanaryEngine
]=]

--[=[
	CanaryEngine's server-sided interface.
	
	@server
	@class CanaryEngineServer
]=]
local CanaryEngineServer = { }

--[=[
	CanaryEngine's client-sided interface.
	
	@client
	@class CanaryEngineClient
]=]
local CanaryEngineClient = { }

--[=[
	A simple reference to the [Players.LocalPlayer].

	@prop Player Player
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	A simple reference to the [Player.Character].

	@prop Character Character & Model
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	A simple reference to the [Player.PlayerGui], useful for automatic typing and API simplicity.

	@prop PlayerGui StarterGui
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	A simple reference to the player's [Backpack], useful for automatic typing and API simplicity.

	@prop PlayerBackpack StarterPack
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	CanaryEngine's global-sided interface.
	
	@class CanaryEngineReplicated
]=]
local CanaryEngineReplicated = { }

-- // Variables

local PlayerService = game:GetService("Players")
local EngineVendor = script.Parent.Vendor

-- // Types

local Types = require(EngineVendor.Types) -- The types used for all libraries inside of the framework

----

local Controllers = require(EngineVendor.Controllers.Controllers)
local Network = Controllers.NetworkController -- Networking logic
local Signal = Controllers.SignalController -- Signal logic

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

-- // Functions

--[=[
	Gets the server-sided interface of CanaryEngine
	
	@server
	@return CanaryEngineServer?
]=]
function CanaryEngine.GetEngineServer()
	if RuntimeContext.Server then
		CanaryEngineServer.Data = require(EngineVendor.Libraries.EasyProfile.EasyProfile)
		return CanaryEngineServer
	else
		Debugger.Debug(error, "Failed to fetch 'EngineServer', context must be server")
		return
	end
end

--[=[
	Gets the client-sided interface of CanaryEngine
	
	@yields
	@client
	@return CanaryEngineClient?
]=]
function CanaryEngine.GetEngineClient()
	if RuntimeContext.Client then
		local Player = PlayerService.LocalPlayer

		CanaryEngineClient.Player = Player :: Player
		CanaryEngineClient.PlayerGui = Player:WaitForChild("PlayerGui") :: typeof(game:GetService("StarterGui"))
		CanaryEngineClient.PlayerBackpack = Player:WaitForChild("Backpack") :: typeof(game:GetService("StarterPack"))

		return CanaryEngineClient
	else
		Debugger.Debug(error, "Failed to fetch 'EngineClient', Context must be client.")
		return
	end
end

--[=[
	Gets the global-sided interface of CanaryEngine. Recommended that use this only in replicated packages, this is a bad practice anywhere else.
	
	@return CanaryEngineReplicated?
]=]
function CanaryEngine.GetEngineReplicated()
	return CanaryEngineReplicated
end

--[=[
	Creates a new network controller on the client, with the name of `controllerName`

	:::tip

	You can set the data type of a network controller after it being made like the following:

	```lua
	local NetworkController: CanaryEngine.ClientNetworkController<boolean> = EngineClient.CreateNetworkController("MyNewNetworkController") -- assuming you are sending over and recieving a boolean
	```
	:::

	@yields
	
	@param controllerName string -- The name of the controller
	@param controllerTimeout number? -- Sets the maximum timeout when waiting for network controllers on the server, defaults to 3 seconds

	@return ClientNetworkController<any>
]=]
function CanaryEngineClient.CreateNetworkController(controllerName: string): Types.ClientNetworkController<any, any>
	if not CanaryEngine.Runtime.RuntimeObjects.NetworkControllers[controllerName] then
		local NewNetworkController = Network.NewClientController(controllerName)

		CanaryEngine.Runtime.RuntimeObjects.NetworkControllers[controllerName] = NewNetworkController
	end
	
	return CanaryEngine.Runtime.RuntimeObjects.NetworkControllers[controllerName]
end

function CanaryEngineClient.GetPlayerCharacter(): Types.Character & Model
	return PlayerService.LocalPlayer.Character or PlayerService.LocalPlayer.CharacterAdded:Wait()
end

--[=[
	Creates a new network controller on the server, with the name of `controllerName`

	:::tip

	You can set the data type of a network controller after it being made like the following:

	```lua
	local NetworkController: CanaryEngine.ServerNetworkController<number> = EngineServer.CreateNetworkController("MyNewNetworkController") -- assuming you are sending over and recieving a number
	```

	:::
	
	@param controllerName string -- The name of the controller
	@return ServerNetworkController<any>
]=]
function CanaryEngineServer.CreateNetworkController(controllerName: string): Types.ServerNetworkController<any, any>
	if not CanaryEngine.Runtime.RuntimeObjects.NetworkControllers[controllerName] then
		local NewNetworkController = Network.NewServerController(controllerName)

		CanaryEngine.Runtime.RuntimeObjects.NetworkControllers[controllerName] = NewNetworkController
	end

	return CanaryEngine.Runtime.RuntimeObjects.NetworkControllers[controllerName]
end

--[=[
	Creates a new signal that is then given a reference in the signals table. Create a new anonymous signal by leaving the name blank.
	
	@param signalName string -- The name of the signal
	@return SignalController<any>
]=]
function CanaryEngine.CreateSignal(signalName: string?): Types.SignalController<any>
	if not signalName then
		return Signal.NewController("Anonymous")
	end

	if not CanaryEngine.Runtime.RuntimeObjects.SignalControllers[signalName] then
		local NewSignal = Signal.NewController(signalName)

		CanaryEngine.Runtime.RuntimeObjects.SignalControllers[signalName] = NewSignal
	end

	return CanaryEngine.Runtime.RuntimeObjects.SignalControllers[signalName]
end

--[=[
	Creates a new anonymous signal, this does not have a reference outside of the variable it was created in. This is also technically an alias for CanaryEngine.CreateSignal(nil).
	
	@return SignalController<any>
]=]
function CanaryEngine.CreateAnonymousSignal(): Types.SignalController<any>
	return Signal.NewController("Anonymous")
end

-- // Actions

return CanaryEngine