-- // Package

local Package = { }

local InternalPackages = script.Packages

-- // Variables

local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")

local StartupData = {StartTime = 0; IsStarted = false;}
local LocalStartupData = {StartTime = 0; IsStarted = false;}

local CanaryEngineServer = { }
local CanaryEngineClient = { }

local CanaryEngine = ReplicatedStorage.CanaryEngine

local EngineSignal = require(InternalPackages.EngineSignal)
local EngineConsole, console = require(script.Console), require(script.Console)
local EngineTypes = require(InternalPackages.EngineTypes)
local EngineUtility = require(InternalPackages.EngineUtility)
local EngineNetworkSignal = require(InternalPackages.BridgeNet)
local EngineStartup = require(script.Startup)

local IsStudio = RunService:IsStudio()

Package.Console = EngineConsole

-- // Functions

local SetupServer = function()
	local StartTime = os.clock()

	EngineStartup.SetupFolders("Server")
	EngineStartup.SetupFolders("Client")
	EngineStartup.SetupFolders("Global")

	EngineStartup.FinalizeSetup()

	console.warn("CanaryEngine is not ready for stable use; bugs will be present. Contact Canary if you find any bugs.")

	local EndTime = (os.clock() - StartTime) * 1000

	StartupData.IsStarted = true
	StartupData.StartTime = EndTime

	Package.GetLatestPackageVersion(script.Parent, true)
	CanaryEngine:SetAttribute("EngineStarted", true)
end

--[[

	Starts the server and then will automatically replicate
	all client folders. Allows you to use the server-sided
	version of cEngine.
	
	@returns [dictionary] EngineServer
	
--]]

function Package.GetEngineServer()
	if RunService:IsServer() then
		
		CanaryEngineServer.Packages = ServerStorage:WaitForChild("EngineServer").Packages :: Folder
		CanaryEngineServer.Media = ServerStorage:WaitForChild("EngineServer").Media :: Folder
		
		return CanaryEngineServer
	else
		console.silentError("Could not fetch table 'EngineServer'.")
	end
end

--[[

	Allows you to use the client sided version of cEngine.
	
	@returns [dictionary] EngineClient
	
--]]

function Package.GetEngineClient()
	if RunService:IsClient() then
		
		CanaryEngineClient.Packages = ReplicatedStorage:WaitForChild("EngineClient").Packages :: Folder
		CanaryEngineClient.Media = ReplicatedStorage:WaitForChild("EngineClient").Media :: Folder
		
		CanaryEngineClient.Player = PlayerService.LocalPlayer :: Player
		
		return CanaryEngineClient
	else
		console.silentError("Could not fetch table 'EngineClient'.")
	end
end

--[[

	Creates a client-sided `NetworkSignal`.
	
	@returns [NetworkSignalClient] A client-sided NetworkSignal object.
	
--]]

function CanaryEngineClient.CreateNetworkSignal(id: string | number): EngineTypes.NetworkSignalClient
	return EngineNetworkSignal.CreateBridge(tostring(id))
end

--[[

	Creates a `ScriptSignal`, can be used in the same RunContext.
	
	@param [(string|number)] id - The name/id of the signal.
	
	@returns [CustomScriptSignal] A user-created `ScriptSignal` object.
	
--]]

function Package.CreateSignal(): EngineTypes.CustomScriptSignal
	return EngineSignal.new()
end

--[[

	Creates a server-sided `NetworkSignal`.
	
	@param [(string|number)] id - The name/id of the signal.
	
	@returns [NetworkSignalServer] A server-sided `NetworkSignal` object.
	
--]]

function CanaryEngineServer.CreateNetworkSignal(id: string | number): EngineTypes.NetworkSignalServer
	return EngineNetworkSignal.CreateBridge(tostring(id))
end

--[[

	Gets `DataService` from the services folder. This is the default data package.
	
	@returns [DataService] The data storing method used by cEngine.
	
--]]

function CanaryEngineServer.GetDataService()
	return require(InternalPackages.DataService)
end

--[[

	Gets the start time of EngineServer.
	
	@returns [?number] The amount of time (in ms) cEngine took to start.
	
--]]

function Package.GetStartupTime(): number?
	if StartupData.IsStarted then
		return StartupData.StartTime
	else
		console.warn("Engine not started.")
		return nil
	end
end

--[[

	Returns the latest version of a package. You can also log a warning
	in the console if you wish
	
	@param [ModuleScript] package - The package to check the version of,
	must have a `VersionNumber` and `PackageId` attribute, and the asset
	must have a 'Version: (number)' in its description.
	
	@param [?boolean] warnIfNotLatestVersion - An option to log a warning
	if the package version isn't the latest.
	
	@returns [?number] The fetched version, may be nil if there was an
	error fetching the version
	
--]]

function Package.GetLatestPackageVersion(package: Instance, warnIfNotLatestVersion: boolean?): number?
	console.assert(package:GetAttribute("PackageId") ~= nil, "Package must have a valid 'PackageId'")
	console.assert(package:GetAttribute("VersionNumber") ~= nil, "Package must have a valid 'VersionNumber'")
	
	console.assert(package:GetAttribute("PackageId") ~= 0, "Cannot have a PackageId of zero.")
	
	warnIfNotLatestVersion = EngineUtility.optionalParam(warnIfNotLatestVersion, true)
	
	local MarketplaceInfo
	local success, err = pcall(function()
		MarketplaceInfo = MarketplaceService:GetProductInfo(package:GetAttribute("PackageId"))
	end)
	
	if success then
		local FetchedVersion = string.match(MarketplaceInfo.Description, "Version: %d+")
		
		if not FetchedVersion then
			console.error("Asset description must have 'Version: (number)")
		end
		
		local SplitFetchedVersion = tonumber(string.split(FetchedVersion, " ")[2])
		
		if SplitFetchedVersion ~= package:GetAttribute("VersionNumber") then
			if warnIfNotLatestVersion then
				console.warn(`Package '{MarketplaceInfo.Name}' is not up-to-date. Available version: {SplitFetchedVersion}`)
			end
			return SplitFetchedVersion
		else
			if IsStudio then
				console.log(`Package '{MarketplaceInfo.Name}' is up-to-date.`)
			else
				console.silentLog("Package is up-to-date.")
			end
			return SplitFetchedVersion
		end
	else
		console.silentError(`There was an error fetching package info, retry. '{err}'`)
		return nil
	end
end

-- // Actions

if RunService:IsServer() and not StartupData.IsStarted then SetupServer() end

return Package
