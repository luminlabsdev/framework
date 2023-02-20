-- // Package

local Package = { }

local CanaryEngineServer = { }
local CanaryEngineClient = { }

-- // Types

--[[

	The ScriptConnection type is very similar to the
	RBXScriptConnection.
	
	@private
	@typedef [{
		Disconnect: (self: ScriptConnection) -> ();
		Connected: boolean;
	}] ScriptConnection
	
--]]

type ScriptConnection = {
	Disconnect: (self: ScriptConnection) -> ();
	Connected: boolean;
}

--[[

	The ScriptSignal type is very similar to the
	RBXScriptSignal.
	
	@private
	@typedef [{
		Connect: (self: ScriptSignal<T...>?, func: (T...) -> ()) -> (ScriptConnection);
		Wait: (self: ScriptSignal<T...>?) -> (T...);
		Once: (self: ScriptSignal<T...>?, func: (T...) -> ()) -> (ScriptConnection);
		ConnectParallel: (self: ScriptSignal<T...>?, func: (T...) -> ()) -> (ScriptConnection);
	}] ScriptSignal
	
--]]

type ScriptSignal<T...> = {
	Connect: (self: ScriptSignal<T...>?, func: (T...) -> ()) -> (ScriptConnection);
	Wait: (self: ScriptSignal<T...>?) -> (T...);
	Once: (self: ScriptSignal<T...>?, func: (T...) -> ()) -> (ScriptConnection);
}

--[[

	The CustomScriptSignal type is very similar to the
	ScriptSignal type, but it lets you fire info as well.
	
	@public
	@typedef [{
		Connect: (self: CustomScriptSignal, func: (...any) -> ()) -> (ScriptConnection);
		Wait: (self: CustomScriptSignal) -> (...any);
		Once: (self: CustomScriptSignal, func: (...any) -> ()) -> (ScriptConnection);
		Fire: (self: CustomScriptSignal, ...any) -> ();
		ConnectParallel: (self: CustomScriptSignal, func: (...any) -> ()) -> (ScriptConnection);
		DisconnectAll: (self: CustomScriptSignal) -> ()
	}] CustomScriptSignal
	
--]]

export type CustomScriptSignal = {
	Connect: (self: CustomScriptSignal, func: (...any) -> ()) -> (ScriptConnection);
	Wait: (self: CustomScriptSignal) -> (...any);
	Once: (self: CustomScriptSignal, func: (...any) -> ()) -> (ScriptConnection);
	Fire: (self: CustomScriptSignal, ...any) -> ();
	DisconnectAll: (self: CustomScriptSignal) -> ()
}

--[[

	A NetworkSignal is similar to a remote event.
	
	@public
	@typedef [{
	Connect: (self: NetworkSignal, func: (...any) -> ()) -> (ScriptConnection);
	Once: (self: NetworkSignal, func: (...any) -> ()) -> (ScriptConnection);
	FireServer: (self: NetworkSignal, ...any) -> ();
	}] NetworkSignal
	
--]]

type NetworkSignal = { -- sadly bridgenet2 is very limited right now, but it should be find for the time being.
	Connect: (self: NetworkSignal, func: (...any) -> ()) -> ();
	FireServer: (self: NetworkSignal, ...any) -> ();
}

--[[

	A sNetworkSignal is similar to NetworkSignal, but is server-sided.
	
	@public
	@typedef [{
	Connect: (self: sNetworkSignal, func: (player: Player, ...any) -> ()) -> (ScriptConnection);
	Once: (self: sNetworkSignal, func: (player: Player, ...any) -> ()) -> (ScriptConnection);
	FireClient: (self: sNetworkSignal, player: Player, ...any) -> ();
	FireAllClients: (self: sNetworkSignal, ...any) -> ();
	FireMultipleClients: (self: sNetworkSignal, players: {Player}, ...any) -> ();
	FireAllClientsExcept: (self: sNetworkSignal, blacklisted: {Player} | Player, ...any) -> ();
	}] sNetworkSignal
	
--]]


type sNetworkSignal = {
	Connect: (self: sNetworkSignal, func: (player: Player, ...any) -> ()) -> ();
	FireClient: (self: sNetworkSignal, player: Player, ...any) -> ();
	FireAllClients: (self: sNetworkSignal, ...any) -> ();
	FireMultipleClients: (self: sNetworkSignal, players: {Player}, ...any) -> ();
	FireAllClientsExcept: (self: sNetworkSignal, blacklisted: {Player} | Player, ...any) -> ();
}

-- // Variables

local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

local CanaryEngine = ReplicatedStorage:WaitForChild("CanaryEngineFramework")
local PreinstalledPackages = CanaryEngine.CanaryEngine.Packages

local Startup = require(script.Startup)
local Debugger = require(script.Debugger)
local Runtime = require(script.Runtime) -- Get the RuntimeSettings, which are settings that are set during runtime

local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

--

local Signal = require(PreinstalledPackages.Signal)
local BridgeNet2 = require(PreinstalledPackages.BridgeNet2)

-- // Functions

local function nilparam<a>(arg: a?, def: a): a
	if arg == nil then
		return def
	else
		return arg
	end
end

--[[

	Allows you to use the server sided version of cEngine.
	
	@public
	@returns [dictionary] EngineServer
	
--]]

function Package.GetEngineServer()
	if RuntimeContext.Server then
		CanaryEngineServer.Packages = {
			Server = ServerStorage:WaitForChild("EngineServer").Packages :: typeof(CanaryEngine.Packages.Server);
			Global = ReplicatedStorage:WaitForChild("EngineGlobal").Packages :: typeof(CanaryEngine.Packages.Global);
		}

		CanaryEngineServer.Media = ServerStorage:WaitForChild("EngineServer").Media :: typeof(CanaryEngine.Media.Server)
		CanaryEngineServer.PreinstalledPackages = {
			DataService = require(PreinstalledPackages.DataService);
			RandomGenerator = require(PreinstalledPackages.RandomGenerator);
		}

		return CanaryEngineServer
	else
		error("[CanaryEngine]: Could not fetch table 'EngineServer'.")
	end
end

--[[

	Allows you to use the client sided version of cEngine.
	
	@public
	@returns [dictionary] EngineClient
	
--]]

function Package.GetEngineClient()
	if RuntimeContext.Client then
		CanaryEngineClient.Packages = {
			Client = ReplicatedStorage:WaitForChild("EngineClient").Packages :: typeof(CanaryEngine.Packages.Client);
			Global = ReplicatedStorage:WaitForChild("EngineGlobal").Packages :: typeof(CanaryEngine.Packages.Global);
		}

		CanaryEngineClient.Media = ReplicatedStorage:WaitForChild("EngineClient").Media :: typeof(CanaryEngine.Media.Client)
		CanaryEngineClient.Player = PlayerService.LocalPlayer :: Player
		CanaryEngineClient.PreinstalledPackages = {
			RandomGenerator = require(PreinstalledPackages.RandomGenerator);
		}

		return CanaryEngineClient
	else
		error("[CanaryEngine]: Could not fetch table 'EngineClient'.")
	end
end

--[[

	Creates a `NetworkSignal`, can be used in the other types of RunContexts.
	
	@public
	@returns [NetworkSignal] Similar to a remote event, but client-sided.
	
--]]

function CanaryEngineClient.CreateNetworkSignal(name: string): NetworkSignal
	return BridgeNet2.ReferenceBridge(name)
end

--[[

	Creates a `NetworkSignal`, can be used in the other types of RunContexts.
	
	@public
	@returns [sNetworkSignal] Similar to a remote event, but server-sided.
	
--]]

function CanaryEngineServer.CreateNetworkSignal(name: string): sNetworkSignal
	return BridgeNet2.ReferenceBridge(name)
end

--[[

	Creates a `ScriptSignal`, can be used in the same RunContext.
	
	@public
	@returns [CustomScriptSignal] A user-created `ScriptSignal` object.
	
--]]

function Package.CreateSignal(): CustomScriptSignal
	return Signal.new()
end

--[[

	Returns the latest version of a package. You can also log a warning
	in the console if you wish
	
	@param [ModuleScript] package - The package to check the version of,
	must have a `VersionNumber` and `PackageId` attribute, and the asset
	must have a 'Version: (number)' in its description.
	
	@param [?boolean] warnIfNotLatestVersion - An option to log a warning
	if the package version isn't the latest.
	
	@public
	
	@returns [?number] The fetched version, may be nil if there was an
	error fetching the version
	
--]]

function Package.GetLatestPackageVersionAsync(package: Instance, warnIfNotLatestVersion: boolean?): number?
	Debugger.assertmulti(
		{package:GetAttribute("PackageId") ~= nil, "Package must have a valid 'PackageId'"},
		{package:GetAttribute("VersionNumber") ~= nil, "Package must have a valid 'VersionNumber'"},
		{package:GetAttribute("PackageId") ~= 0, "Cannot have a PackageId of zero."}
	)
	
	warnIfNotLatestVersion = nilparam(warnIfNotLatestVersion, true)
	
	local MarketplaceInfo
	local Success, Error = pcall(function()
		MarketplaceInfo = MarketplaceService:GetProductInfo(package:GetAttribute("PackageId"))
	end)
	
	if not Success and Error then
		warn(`Could not fetch version: {Error}`)
		return nil
	end
	
	local FetchedVersion = string.match(MarketplaceInfo.Description, "Version: %d+")
		
	if not FetchedVersion then
		error("Asset description must have 'Version: (number)")
	end
	
	local SplitFetchedVersion = tonumber(string.split(FetchedVersion, " ")[2])
	
	if SplitFetchedVersion ~= package:GetAttribute("VersionNumber") then
		if warnIfNotLatestVersion then
			warn(`Package '{MarketplaceInfo.Name}' is not up-to-date. Available version: {SplitFetchedVersion}`)
		end
		return SplitFetchedVersion
	end
		
	Debugger.print(`Package '{MarketplaceInfo.Name}' is up-to-date.`)
			
	return SplitFetchedVersion
end

-- // Actions

Startup.StartEngine()

return Package
