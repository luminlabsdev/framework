
-- // CanaryEngine

--[=[
	The parent class of all things CanaryEngine.

	@class CanaryEngine
]=]
local CanaryEngine = { }

--[=[
	The runtime property contains settings that are set during runtime, and the current context of the server/client.

	@prop Runtime {RuntimeSettings: RuntimeSettings, RuntimeContext: RuntimeContext}

	@readonly
	@within CanaryEngine
]=]

--[=[
	Toggles developer mode.

	@prop DeveloperMode boolean

	@private
	@within CanaryEngine
]=]

--[=[
	The libraries property contains useful libraries like Benchmark or Serialize.

	@prop Libraries {Utility: Utility, Benchmark: Benchmark, Statistics: Statistics, Serialize: Serialize}

	@readonly
	@within CanaryEngine
]=]

--[=[
	A child class of CanaryEngine, server-sided.

	@class CanaryEngineServer
]=]
local CanaryEngineServer = { }

--[=[
	A reference to the Media folder on the Server, also gives access to replicated media.

	@prop Media {Server: Folder, Replicated: Folder}
	@server
	@readonly

	@within CanaryEngineServer
]=]

--[=[
	A reference to the Packages folder on the Server, also gives access to replicated Packages.

	@prop Packages {Server: Folder, Replicated: Folder}
	@server
	@readonly

	@within CanaryEngineServer
]=]

--[=[
	A child class of CanaryEngine, client-sided.

	@class CanaryEngineClient
]=]
local CanaryEngineClient = { }

--[=[
	A simple reference to the [Players.LocalPlayer].

	@prop Player Player
	@client
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	A simple reference to the [Player.PlayerGui], useful for automatic typing and API simplicity.

	@prop PlayerGui StarterGui
	@client
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	A simple reference to the player's [Backpack], useful for automatic typing and API simplicity.

	@prop PlayerBackpack StarterPack
	@client
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	Local objects of the player.

	@prop LocalObjects dictionary
	@client
	@readonly
	@deprecated v2 -- Use PlayerBackpack and PlayerGui instead.

	@within CanaryEngineClient
]=]

--[=[
	A reference to the Media folder on the client, also gives access to replicated media.

	@prop Media {Client: Folder, Replicated: Folder}
	@client
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	A reference to the Packages folder on the client, also gives access to replicated Packages.

	@prop Packages {Client: Folder, Replicated: Folder}
	@client
	@readonly

	@within CanaryEngineClient
]=]

-- // Types

--[=[
	A script connection, similar to an [RBXScriptConnection]

	@field Disconnect (self: ScriptConnection) -> ()
	@field Connected boolean

	@interface ScriptConnection
	@within CanaryEngine
	@private
]=]
type ScriptConnection = {
	Disconnect: (self: ScriptConnection) -> (),
	Connected: boolean,
}


--[=[
	A basic script signal, similar to an [RBXScriptSignal]

	@field Connect (self: ScriptSignalBasic<T>?, func: (data: {T}) -> ()) -> (ScriptConnection)
	@field Wait (self: ScriptSignalBasic<T>?) -> ({T})
	@field Once (self: ScriptSignalBasic<T>?, func: (data: {T}) -> ()) -> (ScriptConnection)

	@interface ScriptSignalBasic
	@within CanaryEngine
	@private
]=]
type ScriptSignalBasic<T> = {
	Connect: (self: ScriptSignalBasic<T>?, func: (data: {T}) -> ()) -> (ScriptConnection),
	Wait: (self: ScriptSignalBasic<T>?) -> ({T}),
	Once: (self: ScriptSignalBasic<T>?, func: (data: {T}) -> ()) -> (ScriptConnection),
}

--[=[
	A script signal, similar to a [ScriptSignal]. Please note that this extends to [ScriptSignalBasic]

	@field Fire (self: ScriptSignal<T>?, data: ({T} | T)?) -> ()
	@field DisconnectAll (self: ScriptSignal<T>?) -> ()

	@interface ScriptSignal
	@within CanaryEngine
]=]
export type ScriptSignal<T> = {
	Fire: (self: ScriptSignal<T>?, data: ({T} | T)?) -> (),
	DisconnectAll: (self: ScriptSignal<T>?) -> (),
} & ScriptSignalBasic<T>

--[=[
	The type of the data being sent through a network controller, though it is generally known as a rule that sent data will be converted into a table.

	@type NetworkControllerData ({T} | T)
	@within CanaryEngine
]=]
export type NetworkControllerData<T> = ({T} | T)

--[=[
	A ClientNetworkController is basically a mixed version of a [RemoteEvent] and [RemoteFunction]. It has better features and is more performant.

	@field Connect (self: ClientNetworkController<T>?, func: (data: {T}) -> ()) -> (ScriptConnection)
	@field Once (self: ClientNetworkController<T>?, func: (data: {T}) -> ()) -> (ScriptConnection)
	@field Wait (self: ClientNetworkController<T>?) -> ({T})
	@field Fire (self: ClientNetworkController<T>?, data: ({T} | T)?) -> ()
	
	@field InvokeAsync (self: ClientNetworkController<T>?, data: ({T} | T)?) -> ({T})

	@interface ClientNetworkController
	@within CanaryEngine
]=]
export type ClientNetworkController<T> = {
	Connect: (self: ClientNetworkController<T>?, func: (data: {T}) -> ()) -> (ScriptConnection),
	Wait: (self: ClientNetworkController<T>?) -> ({T}),
	Once: (self: ClientNetworkController<T>?, func: (data: {T}) -> ()) -> (ScriptConnection),
	
	Fire: (self: ClientNetworkController<T>?, data: NetworkControllerData<T>?) -> (),
	InvokeAsync: (self: ClientNetworkController<T>?, data: NetworkControllerData<T>?) -> ({T}),
}

--[=[
	A ServerNetworkController is basically a mixed version of a [RemoteEvent] and [RemoteFunction]. It has better features and is more performant, though this is the server-sided API.

	@field Connect (self: ServerNetworkController<T>?, func: (sender: Player, data: {T}) -> ()) -> (ScriptConnection)
	@field Once (self: ServerNetworkController<T>?, func: (sender: Player, data: {T}) -> ()) -> (ScriptConnection)
	@field Wait (self: ServerNetworkController<T>?) -> (Player, {T})
	@field Fire (self: ServerNetworkController<T>?, recipient: Player | {Player}, data: ({T} | T)?) -> ()
	
	@field OnInvoke (self: ServerNetworkController<T>?, callback: (sender: Player, data: {T}) -> ()) -> ()

	@interface ServerNetworkController
	@within CanaryEngine
]=]
export type ServerNetworkController<T> = {
	Connect: (self: ClientNetworkController<T>?, func: (sender: Player, data: {T}) -> ()) -> (ScriptConnection),
	Wait: (self: ClientNetworkController<T>?) -> (Player, {T}),
	Once: (self: ClientNetworkController<T>?, func: (sender: Player, data: {T}) -> ()) -> (ScriptConnection),
	
	Fire: (self: ServerNetworkController<T>?, recipient: Player | {Player}, data: NetworkControllerData<T>?) -> (),
	OnInvoke: (self: ServerNetworkController<T>?, callback: (sender: Player, data: {T}) -> ({T})) -> ()
}

--[=[
	This is the server sided API for CanaryEngine.

	@field Packages {
		Server: typeof(script.Parent.Packages.Server),
		Replicated: typeof(script.Parent.Packages.Replicated)
	},

	@field Media {
		Server: typeof(script.Parent.Media.Server),
		Replicated: typeof(script.Parent.Media.Replicated)
	},

	@field CreateNetworkController (controllerName: string) -> (ServerNetworkController<any>)

	@interface EngineServer
	@within CanaryEngine
	@private
]=]
type EngineServer = {
	Packages: {
		Server: typeof(script.Parent.Packages.Server),
		Replicated: typeof(script.Parent.Packages.Replicated)
	},

	Media: {
		Server: typeof(script.Parent.Media.Server),
		Replicated: typeof(script.Parent.Media.Replicated)
	},
	
	Matchmaking: typeof(require(script.Vendor.Network.MatchmakingService)),
	Moderation: nil,
	Data: typeof(require(script.Vendor.Data.DataService)),

	CreateNetworkController: (controllerName: string) -> (ServerNetworkController<any>)
}

--[=[
	This is the client sided API for CanaryEngine.

	@field Packages {
		Client: typeof(script.Parent.Packages.Client),
		Replicated: typeof(script.Parent.Packages.Replicated)
	},

	@field Media {
		Client: typeof(script.Parent.Media.Client),
		Replicated: typeof(script.Parent.Media.Replicated)
	},

	@field Player Player,
	@field PlayerGui typeof(game:GetService("StarterGui")),
	@field PlayerBackpack typeof(game:GetService("StarterPack")),
	
	@field CreateNetworkController (controllerName: string) -> (ClientNetworkController<any>)

	@interface EngineClient
	@within CanaryEngine
	@private
]=]
type EngineClient = {
	Packages: {
		Client: typeof(script.Parent.Packages.Client),
		Replicated: typeof(script.Parent.Packages.Replicated)
	},

	Media: {
		Client: typeof(script.Parent.Media.Client),
		Replicated: typeof(script.Parent.Media.Replicated)
	},

	Player: Player,

	PlayerGui: typeof(game:GetService("StarterGui")),
	PlayerBackpack: typeof(game:GetService("StarterPack")),

	CreateNetworkController: (controllerName: string) -> (ClientNetworkController<any>)
}

-- // Variables

local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

if not ReplicatedStorage:FindFirstChild("CanaryEngineFramework") then
	error("CanaryEngine must be parented to DataModel.ReplicatedStorage")
end

local CanaryEngineFramework = ReplicatedStorage:WaitForChild("CanaryEngineFramework")

local Vendor = CanaryEngineFramework.CanaryEngine.Vendor
local Data = Vendor.Data
local Libraries = Vendor.Libraries
local Network = Vendor.Network
local IsDeveloperMode = CanaryEngineFramework:GetAttribute("DeveloperMode")

local Startup = require(script.Startup)
local StartupResult = Startup.StartEngine(IsDeveloperMode)
local Debugger = require(script.Debugger)
local Runtime = require(script.Runtime) -- Get the RuntimeSettings, which are settings that are set during runtime

local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

--

local Signal = require(Libraries.Signal)
local Utility = require(Libraries.Utility)
local Benchmark = require(Libraries.Benchmark)
local Statistics = require(Libraries.Statistics)
local Serialize = require(Data.BlueSerializer)
local NetworkController = require(Network.NetworkController)

CanaryEngine.RuntimeCreatedSignals = { }
CanaryEngine.RuntimeCreatedNetworkControllers = { }

CanaryEngine.Runtime = table.freeze({
	RuntimeSettings = RuntimeSettings,
	RuntimeContext = RuntimeContext,
})

CanaryEngine.Libraries = table.freeze({
	Utility = Utility,
	Benchmark = Benchmark,
	Statistics = Statistics,
	Serialize = Serialize,
})

CanaryEngine.DeveloperMode = IsDeveloperMode

--[=[
	This is the main API for CanaryEngine

	@field GetEngineServer () -> (EngineServer),
	@field GetEngineClient () -> (EngineClient),
	@field CreateSignal () -> (ScriptSignal<any>),
	@field GetLatestPackageVersionAsync (CanaryEngine: Instance, warnIfNotLatestVersion: boolean?, respectDebugger: boolean?) -> (number?),
	
	@field Runtime {
		RuntimeSettings: {
			StudioDebugEnabled: boolean,
			CheckLatestVersion: boolean,
			LiveGameDebugger: boolean,
		},
		
		RuntimeContext {
			Studio: boolean,
			Server: boolean,
			Client: boolean,
			StudioPlay: boolean,
		}
	},
	
	@field Libraries {
		Utility: typeof(Utility),
		Benchmark: typeof(Benchmark),
		Statistics: typeof(Statistics),
		Serialize: typeof(Serialize),
	}
	
	@field DeveloperMode boolean

	@interface CanaryEngine
	@within CanaryEngine
	@private
]=]
type CanaryEngine = {
	GetEngineServer: () -> (EngineServer),
	GetEngineClient: () -> (EngineClient),
	CreateSignal: (signalName: string) -> (ScriptSignal<any>),
	GetLatestPackageVersionAsync: (CanaryEngine: Instance, warnIfNotLatestVersion: boolean?, respectDebugger: boolean?) -> (number?),

	Runtime: {
		RuntimeSettings: {
			StudioDebugEnabled: boolean,
			CheckLatestVersion: boolean,
			LiveGameDebugger: boolean,
		},

		RuntimeContext: {
			Studio: boolean,
			Server: boolean,
			Client: boolean,
			StudioPlay: boolean,
		}
	},

	Libraries: {
		Utility: typeof(Utility),
		Benchmark: typeof(Benchmark),
		Statistics: typeof(Statistics),
		Serialize: typeof(Serialize),
	},

	DeveloperMode: boolean,
}

-- // Functions

--[=[
	Gets the server-sided architecture of CanaryEngine
	
	@server
	@return EngineServer?
]=]
function CanaryEngine.GetEngineServer(): EngineServer?
	if not RuntimeContext.Server then
		Debugger.error("Failed to fetch 'EngineServer', context must be server")
		return nil
	end

	if Runtime.IsStarted() then
		Debugger.warn("Importing a Package while the game is running may cause internal issues, expect errors to occur")
	end

	local EngineServer = ServerStorage:WaitForChild("EngineServer")
	local EngineReplicated = ReplicatedStorage:WaitForChild("EngineReplicated")

	CanaryEngineServer.Packages = {
		Server = EngineServer.Packages,
		Replicated = EngineReplicated.Packages,
	}
	
	CanaryEngineServer.Matchmaking = require(Network.MatchmakingService)
	CanaryEngineServer.Moderation = nil
	CanaryEngineServer.Data = require(Data.DataService)

	CanaryEngineServer.Media = {
		Server = EngineServer.Media,
		Replicated = EngineReplicated.Media,
	}

	return CanaryEngineServer
end

--[=[
	Gets the client-sided architecture of CanaryEngine
	
	@yields
	@client
	@return EngineClient?
]=]
function CanaryEngine.GetEngineClient(): EngineClient?
	if not RuntimeContext.Client then
		Debugger.error("Failed to fetch 'EngineClient', Context must be client.")
		return nil
	end

	if Runtime.IsStarted() then
		Debugger.warn("Importing a Package while the game is running may cause internal issues, expect errors to occur")
	end

	local EngineClient = ReplicatedStorage:WaitForChild("EngineClient")
	local EngineReplicated = ReplicatedStorage:WaitForChild("EngineReplicated")

	local Player = PlayerService.LocalPlayer

	CanaryEngineClient.Packages = {
		Client = EngineClient.Packages,
		Replicated = EngineReplicated.Packages,
	}

	CanaryEngineClient.Media = {
		Client = EngineClient.Media,
		Replicated = EngineReplicated.Media,
	}

	CanaryEngineClient.Player = Player

	CanaryEngineClient.PlayerGui = Player:WaitForChild("PlayerGui")
	CanaryEngineClient.PlayerBackpack = Player:WaitForChild("Backpack")

	return CanaryEngineClient
end

--[=[
	Creates a new network controller on the client, with the name of `controllerName`

	:::tip

	You can set the data type of a network controller after it being made like the following:

	```lua
	local NetworkController: CanaryEngine.ClientNetworkController<boolean> = EngineClient.CreateNetworkController("MyNewNetworkController") -- assuming you are sending over and recieving a boolean
	```
	:::
	
	@param controllerName string -- The name of the controller
	@return ClientNetworkController<any>
]=]
function CanaryEngineClient.CreateNetworkController(controllerName: string): ClientNetworkController<any>
	if not CanaryEngine.RuntimeCreatedNetworkControllers[controllerName] then
		local NewNetworkController = NetworkController.NewClientController(controllerName)

		CanaryEngine.RuntimeCreatedNetworkControllers[controllerName] = NewNetworkController
		return NewNetworkController
	end

	return CanaryEngine.RuntimeCreatedNetworkControllers[controllerName]
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
function CanaryEngineServer.CreateNetworkController(controllerName: string): ServerNetworkController<any>
	if not CanaryEngine.RuntimeCreatedNetworkControllers[controllerName] then
		local NewNetworkController = NetworkController.NewServerController(controllerName)
		
		CanaryEngine.RuntimeCreatedNetworkControllers[controllerName] = NewNetworkController
		return NewNetworkController
	end
	
	return CanaryEngine.RuntimeCreatedNetworkControllers[controllerName]
end

--[=[
	Creates a new signal that is then given a reference in the signals table.
	
	@param signalName string -- The name of the signal
	@return ScriptSignal<any>
]=]
function CanaryEngine.CreateSignal(signalName: string): ScriptSignal<any>
	if not CanaryEngine.RuntimeCreatedSignals[signalName] then
		local NewSignal = Signal.new()
		
		CanaryEngine.RuntimeCreatedSignals[signalName] = NewSignal
		return NewSignal
	end
	
	return CanaryEngine.RuntimeCreatedSignals[signalName]
end

--[=[
	Checks the latest version of the provided package, and returns the latest version if you gave version permissions.

	@yields
	@server
	@error "Asset description must have 'Version: (number) or 'v(number)'" -- This means that the description of your asset uploaded to Roblox does not contain the latter. Example of description:   My awesome new package for CanaryEngine! Version: 3.4.7

	@param package Instance -- The package to check the version of, must have the required attributes.
	@param warnIfNotLatestVersion boolean? -- An optional setting to warn the user if the provided package is not up-to-date, defaults to true.
	@param respectDebugger boolean? -- An optional setting to respect the debugger when warning the user, only applies when `warnIfNotLatestVersion` is true.
	
	@return number?
]=]
function CanaryEngine.GetLatestPackageVersionAsync(package: Instance, warnIfNotLatestVersion: boolean?, respectDebugger: boolean?): number?
	Utility.assertmulti(
		{package:GetAttribute("PackageId") ~= nil, "package must have a valid 'packageId'"},
		{package:GetAttribute("VersionNumber") ~= nil, "package must have a valid 'VersionNumber'"},
		{package:GetAttribute("packageId") ~= 0, "Cannot have a packageId of zero."},
		{package:GetAttribute("CheckLatestVersion") ~= nil, "package must include 'CheckLatestVersion' setting."}
	)

	if not package:GetAttribute("CheckLatestVersion") then
		return nil
	end

	warnIfNotLatestVersion = Utility.nilparam(warnIfNotLatestVersion, true)
	respectDebugger = Utility.nilparam(respectDebugger, true)

	if not RuntimeContext.Server then
		return
	end

	local MarketplaceInfo
	local Success, Error = pcall(function()
		MarketplaceInfo = MarketplaceService:GetProductInfo(package:GetAttribute("PackageId"))
	end)

	if not Success and Error then
		warn(`Could not fetch version: {Error}`)
		return nil
	end

	local FetchedVersion = string.match(MarketplaceInfo.Description, "Version: %d+") or string.match(MarketplaceInfo.Description, "v%d+")

	if not FetchedVersion then
		error("Asset description must have 'Version: (number) or 'v(number)'")
	end

	local SplitFetchedVersion = tonumber(string.split(FetchedVersion, " ")[2])

	if SplitFetchedVersion < package:GetAttribute("VersionNumber") then
		error("Package version cannot be greater than live package version.")
	end

	if SplitFetchedVersion ~= package:GetAttribute("VersionNumber") then
		if warnIfNotLatestVersion then
			if respectDebugger then
				Debugger.warn(`Package '{MarketplaceInfo.Name}' is not up-to-date. Available version: {SplitFetchedVersion}`)
				return SplitFetchedVersion
			end
			warn(`Package '{MarketplaceInfo.Name}' is not up-to-date. Available version: {SplitFetchedVersion}`)
		end
		return SplitFetchedVersion
	end

	Debugger.print(`Package '{MarketplaceInfo.Name}' is up-to-date.`)

	return SplitFetchedVersion
end

-- // Actions

CanaryEngine.GetLatestPackageVersionAsync(script.Parent :: Instance)

return table.freeze(CanaryEngine :: CanaryEngine)