-- // CanaryEngine

--[=[
	The parent of all classes.

	@class CanaryEngine
]=]
local CanaryEngine = { }

--[=[
	The runtime property contains settings that are set during runtime, and the current context of the server/client.

	@prop Runtime {RuntimeSettings: RuntimeSettings, RuntimeContext: RuntimeContext, RuntimeObjects: {NetworkControllers: {[string]: (ServerNetworkController | ServerNetworkController)}, SignalControllers: {[string]: ScriptSignal}}}

	@readonly
	@within CanaryEngine
]=]

--[=[
	The libraries property contains useful libraries like Benchmark or Serialize.

	@prop Libraries {Utility: Utility, Benchmark: Benchmark, Statistics: Statistics, Serialize: Serialize}

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
	A reference to the Media folder on the Server, also gives access to replicated media.

	@deprecated v3.1.5 -- Deprecated in favor of newer and better package systems

	@prop Media {Server: Folder, Replicated: Folder}
	@readonly

	@within CanaryEngineServer
]=]

--[=[
	A reference to the Packages folder on the Server, also gives access to replicated Packages.

	@deprecated v3.1.5 -- Deprecated in favor of newer and better package systems

	@prop Packages {Server: Folder, Replicated: Folder}
	@readonly

	@within CanaryEngineServer
]=]

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
	Local objects of the player.

	@prop LocalObjects dictionary
	@readonly
	@deprecated v2 -- Use PlayerBackpack and PlayerGui instead.

	@within CanaryEngineClient
]=]

--[=[
	A reference to the Media folder on the client, also gives access to replicated media.

	@deprecated v3.1.5 -- Deprecated in favor of newer and better package systems

	@prop Media {Client: Folder, Replicated: Folder}
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	A reference to the Packages folder on the client, also gives access to replicated Packages.

	@deprecated v3.1.5 -- Deprecated in favor of newer and better package systems

	@prop Packages {Client: Folder, Replicated: Folder}
	@readonly

	@within CanaryEngineClient
]=]

--[=[
	CanaryEngine's global-sided interface.
	
	@class CanaryEngineReplicated
]=]
local CanaryEngineReplicated = { }

--[=[
	A reference to the Packages folder that is replicated.

	@deprecated v3.1.5 -- Deprecated in favor of newer and better package systems

	@prop Packages Folder
	@readonly

	@within CanaryEngineReplicated
]=]

--[=[
	A reference to the Media folder that is replicated.

	@deprecated v3.1.5 -- Deprecated in favor of newer and better package systems

	@prop Media Folder
	@readonly

	@within CanaryEngineReplicated
]=]

-- // Types

local Types = require(script.Vendor.Types) -- The types used for all libraries inside of the framework

--[=[
	This is the server sided API for CanaryEngine.

	@field Packages {Server: Folder, Folder}
	@field Media {Server: Folder, Replicated: Folder}
	@field CreateNetworkController (controllerName: string) -> (ServerNetworkController<any, any>)

	@interface EngineServer
	@within CanaryEngine
	@private
]=]
type EngineServer = {
	Packages: {
		Server: typeof(game:GetService("ServerStorage").EngineServer.Packages),
		Replicated: typeof(game:GetService("ReplicatedStorage").EngineReplicated.Packages)
	},

	Media: {
		Server: typeof(game:GetService("ServerStorage").EngineServer.Media),
		Replicated: typeof(game:GetService("ReplicatedStorage").EngineReplicated.Media)
	},

	Data: typeof(require(script.Vendor.Data.EasyProfile)),
	CreateNetworkController: (controllerName: string) -> (Types.ServerNetworkController<any, any>),
}

--[=[
	This is the client sided API for CanaryEngine.

	@field Packages {Client: Folder, Replicated: Folder}
	@field Media {Client: Folder, Replicated: Folder}
	@field Player Player
	@field PlayerGui StarterGui
	@field PlayerBackpack StarterPack
	
	@field CreateNetworkController (controllerName: string) -> (ClientNetworkController<any, any>)

	@interface EngineClient
	@within CanaryEngine
	@private
]=]
type EngineClient = {
	Packages: {
		Client: typeof(game:GetService("ReplicatedStorage").EngineClient.Packages),
		Replicated: typeof(game:GetService("ReplicatedStorage").EngineReplicated.Packages)
	},

	Media: {
		Client: typeof(game:GetService("ReplicatedStorage").EngineClient.Media),
		Replicated: typeof(game:GetService("ReplicatedStorage").EngineReplicated.Media)
	},

	Player: Player,

	PlayerGui: typeof(game:GetService("StarterGui")),
	PlayerBackpack: typeof(game:GetService("StarterPack")),
	 
	CreateNetworkController: (controllerName: string) -> (Types.ClientNetworkController<any, any>),
}

--[=[
	This is the global sided API for CanaryEngine.

	@field Packages {Replicated: Folder}
	@field Media {Replicated: Folder}

	@interface EngineReplicated
	@within CanaryEngine
	@private
]=]
type EngineReplicated = {
	Packages: {
		Replicated: typeof(game:GetService("ReplicatedStorage").EngineReplicated.Packages),
	},
	
	Media: {
		Replicated: typeof(game:GetService("ReplicatedStorage").EngineReplicated.Media),
	},
}

-- // Variables

local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

local Vendor = script.Vendor
local DataFolder = Vendor.Data
local LibrariesFolder = Vendor.Libraries

local Network = require(Vendor.Controllers.Vendor.NetworkController) -- Networking logic
local Signal = require(Vendor.Controllers.Vendor.SignalController) -- Signal logic

local Debugger = require(Vendor.Debugger) -- Easy debug logic
local Runtime = require(Vendor.Runtime) -- Runtime settings + debugger

local Utility = require(LibrariesFolder.Utility)
local Benchmark = require(LibrariesFolder.Benchmark)
local Statistics = require(LibrariesFolder.Statistics)
local Serialize = require(DataFolder.BlueSerializer)

local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

CanaryEngine.RuntimeCreatedSignals = { }
CanaryEngine.RuntimeCreatedNetworkControllers = { }

CanaryEngine.Runtime = table.freeze({
	RuntimeSettings = RuntimeSettings,
	RuntimeContext = RuntimeContext,
	RuntimeObjects = {
		NetworkControllers = CanaryEngine.RuntimeCreatedNetworkControllers,
		SignalControllers = CanaryEngine.RuntimeCreatedSignals,
	},
})

CanaryEngine.Libraries = table.freeze({
	Utility = Utility,
	Benchmark = Benchmark,
	Statistics = Statistics,
	Serialize = Serialize,
})

CanaryEngine.Types = Types

--[=[
	This is the main API for CanaryEngine

	@field GetEngineServer () -> (EngineServer),
	@field GetEngineClient () -> (EngineClient),
	@field CreateSignal (signalName: string) -> (ScriptSignal<any>),
	@field CreateAnonymousSignal () -> (ScriptSignal<any>),
	@field GetLatestPackageVersionAsync (CanaryEngine: Instance, warnIfNotLatestVersion: boolean?, respectDebugger: boolean?) -> (number?),
	@field Runtime {RuntimeSettings: {StudioDebugEnabled: boolean, Version: number, LiveGameDebugger: boolean}, RuntimeContext: {Studio: boolean, Server: boolean, Client: boolean, StudioPlay: boolean}, RuntimeObjects: },
	@field Libraries {Utility: Utility, Benchmark: Benchmark, Statistics: Statistics, Serialize: Serialize}
	@field RuntimeCreatedSignals {[string]: ScriptSignal<any>}
	@field RuntimeCreatedNetworkControllers {[string]: ServerNetworkController<any, any> | ClientNetworkController<any, any>}

	@interface CanaryEngine
	@within CanaryEngine
	@private
]=]

type CanaryEngine = {
	GetEngineServer: () -> (EngineServer),
	GetEngineClient: () -> (EngineClient),
	GetEngineReplicated: () -> (EngineReplicated),
	 
	CreateSignal: (signalName: string) -> (Types.ScriptSignal<any>),
	CreateAnonymousSignal: () -> (Types.ScriptSignal<any>),

	GetLatestPackageVersionAsync: (package: Instance, warnIfNotLatestVersion: boolean?, respectDebugger: boolean?) -> (number?),

	Runtime: {
		RuntimeSettings: {
			StudioDebugEnabled: boolean,
			CheckLatestVersion: boolean,
			Version: number,
		},

		RuntimeContext: {
			Studio: boolean,
			Server: boolean,
			Client: boolean,
			StudioPlay: boolean,
		},

		RuntimeObjects: {
			NetworkControllers: {[string]: Types.ServerNetworkController<any, any> | Types.ClientNetworkController<any, any>},
			SignalControllers: {[string]: Types.ScriptSignal<any>}
		},
	},

	Libraries: {
		Utility: typeof(Utility),
		Benchmark: typeof(Benchmark),
		Statistics: typeof(Statistics),
		Serialize: typeof(Serialize),
	},
	 
	RuntimeCreatedSignals: {[string]: Types.ScriptSignal<any>},
	RuntimeCreatedNetworkControllers: {[string]: Types.ServerNetworkController<any, any> | Types.ClientNetworkController<any, any>}
}

-- // Functions

--[=[
	Gets the server-sided interface of CanaryEngine
	
	@server
	@return EngineServer?
]=]
function CanaryEngine.GetEngineServer(): EngineServer?
	if not RuntimeContext.Server then
		Debugger.error("Failed to fetch 'EngineServer', context must be server")
		return nil
	end

	local EngineServer = ServerStorage:WaitForChild("EngineServer")
	local EngineReplicated = ReplicatedStorage:WaitForChild("EngineReplicated")

	CanaryEngineServer.Packages = {
		Server = EngineServer.Packages,
		Replicated = EngineReplicated.Packages,
	}

	CanaryEngineServer.Data = require(DataFolder.EasyProfile)

	CanaryEngineServer.Media = {
		Server = EngineServer.Media,
		Replicated = EngineReplicated.Media,
	}

	return CanaryEngineServer
end

--[=[
	Gets the client-sided interface of CanaryEngine
	
	@yields
	@client
	@return EngineClient?
]=]
function CanaryEngine.GetEngineClient(): EngineClient?
	if not RuntimeContext.Client then
		Debugger.error("Failed to fetch 'EngineClient', Context must be client.")
		return nil
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
	Gets the global-sided interface of CanaryEngine. Recommended that use this only in replicated packages, this is a bad practice anywhere else.
	
	@return EngineReplicated?
]=]
function CanaryEngine.GetEngineReplicated(): EngineReplicated?
	local EngineReplicated = ReplicatedStorage:WaitForChild("EngineReplicated")

	CanaryEngineReplicated.Packages = EngineReplicated.Packages
	CanaryEngineReplicated.Media = EngineReplicated.Media

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
	@param timeout number? -- The maxmimum amount of time to wait until the client errors
	
	@return ClientNetworkController<any>
]=]
function CanaryEngineClient.CreateNetworkController(controllerName: string, timeout: number?): Types.ClientNetworkController<any, any>
	if not CanaryEngine.RuntimeCreatedNetworkControllers[controllerName] then
		local NewNetworkController = Network.NewClientController(controllerName)

		CanaryEngine.RuntimeCreatedNetworkControllers[controllerName] = NewNetworkController
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
function CanaryEngineServer.CreateNetworkController(controllerName: string): Types.ServerNetworkController<any, any>
	if not CanaryEngine.RuntimeCreatedNetworkControllers[controllerName] then
		local NewNetworkController = Network.NewServerController(controllerName)

		CanaryEngine.RuntimeCreatedNetworkControllers[controllerName] = NewNetworkController
	end

	return CanaryEngine.RuntimeCreatedNetworkControllers[controllerName]
end

--[=[
	Creates a new signal that is then given a reference in the signals table. Create a new anonymous signal by leaving the name blank.
	
	@param signalName string -- The name of the signal
	@return ScriptSignal<any>
]=]
function CanaryEngine.CreateSignal(signalName: string?): Types.ScriptSignal<any>
	if not signalName then
		return Signal.NewController("Anonymous")
	end

	if not CanaryEngine.RuntimeCreatedSignals[signalName] then
		local NewSignal = Signal.NewController(signalName)

		CanaryEngine.RuntimeCreatedSignals[signalName] = NewSignal
	end

	return CanaryEngine.RuntimeCreatedSignals[signalName]
end

--[=[
	Creates a new anonymous signal, this does not have a reference outside of the variable it was created in.
	
	@return ScriptSignal<any>
]=]
function CanaryEngine.CreateAnonymousSignal(): Types.ScriptSignal<any>
	return Signal.NewController("Anonymous")
end

--[=[
	Checks the latest version of the provided package, and returns the latest version if you gave version permissions.

	@deprecated v3.1.4 -- Deprecated in favor of newer and better package systems
	
	:::caution

	If you come across the error "package must have a valid 'VersionNumber'", that means the description of your asset does not contain the current version of your asset. This is required to compare versions.

	:::

	@yields
	@server

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

return CanaryEngine :: CanaryEngine