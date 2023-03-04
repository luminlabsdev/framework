-- // Package

local Package = {
	Utility = { };
	Benchmark = { };
	Serialize = require(script.Packages.ThirdParty.BlueSerializer)

}

local CanaryEngineServer = { }
local CanaryEngineClient = { }
local BenchmarkMethods = { }

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
	Fire: (self: CustomScriptSignal, data: {any}?) -> ();
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

type ClientNetworkSignal = {
	Connect: (self: ClientNetworkSignal, func: (...any) -> ()) -> ();
	Fire: (self: ClientNetworkSignal, data: {any}?) -> ();
}

type ServerNetworkSignal = {
	Connect: (self: ServerNetworkSignal, func: (recipient: Player, ...any) -> ()) -> ();
	Fire: (self: ServerNetworkSignal, recipient: Player | {Player}, data: {any}?) -> ();
}

type table = {}

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

local Signal = require(PreinstalledPackages.ThirdParty.Signal)
local BridgeNet2 = require(PreinstalledPackages.ThirdParty.BridgeNet2)

-- // Functions

--[[

	Checks if a is nil and returns a default value, otherw-
	ise it returns the provided param to be checked.
	
	@param [any] param - The parameter to check if nil.
	@param [any] default - The value to replace `param`
	if it is nil.
	
	@public
	@returns [any] 
	
--]]

function Package.Utility.nilparam<a>(param: a?, default: a): a
	if param == nil then
		return default
	else
		return param
	end
end

--[[

	Checks if the provided value is nil or false, then throws
	an error. If the value doesn't resolve to nil or false,
	then the assertion will be returned.
	
	@param [any] assertion - The value to be asserted.
	@param [any] msg - The message to send if the value
	is not truthy or nil.
	
	@public
	@returns [?any] 
	
--]]

function Package.Utility.assert<a, b>(assertion: a, msg: b): a?
	if not (assertion) then
		error(msg, 0)
		return nil
	end
	
	return assertion
end

--[[

	Similar to assert, but you can use a custom error
	handler.
	
	@param [any] assertion - The value to be asserted.
	@param [function] handler - The function to be ran
	if `assertion` resolves to false or nil.
	
	@public
	@returns [void] 
	
--]]

function Package.Utility.xassert<a>(assertion: a, handler: () -> ())
	if not (assertion) then
		handler()
	end
end

--[[

	Does the same thing as assert, but takes multiple tables
	of assertions and errors for optimization and simplicity.
	
	@param [{assertion | msg}] - Same as assert, but takes
	multiple values to cut down on function calls.
	
	Example:
	
	```
	local value1 = true
	local value2 = false
	local value3 = nil
	
	assertmulti(
		{value1, "Value1 is nil!"}, -- no error
		{value2, "Value2 is nil!"}, -- error (will stop the thread before Value3 is checked)
		{value3, "Value3 is nil!"}, -- error
	)
	```
	
	@public
	@returns [?any] 
	
--]]

function Package.Utility.assertmulti<a, b>(...: {a | b})
	for index, value in {...} do
		if not value[1] then
			error(value[2], 0)
		end
	end
end

--[[

	Deep copies the provided table. When deep copying, tables
	nested inside the provided table will be copied as well,
	where this usually isn't the case.
	
	@param [array] t - The array that should be deep copied.
	
	@public
	@returns [array] 
	
--]]

function Package.Utility.DeepCopy(t: {[number]: any}): {[number]: any}
	local copied = { }
	
	if type(t) ~= "table" then
		Debugger.silenterror(`Field 't' expected array, got {typeof(t)}.`)
	end
	
	for index, value in t do
		if type(value) == "table" then
			value = Package.Utility.DeepCopy(value)
		end
		copied[index] = value
	end
	
	return copied
end

--[[

	Returns true if the provided table is a dictionary, while
	false if not.
	
	@param [dictionary | array] param - The parameter to check if nil.
	
	@public
	@returns [boolean] 
	
--]]

function Package.Utility.IsDictionary(t: table): boolean?
	if type(t) ~= "table" then
		Debugger.silenterror(`Field 't' expected table, got {typeof(t)}.`)
		return
	end
	if not t[1] then
		return true
	else
		return false
	end
end

--[[

	Converts a dictionary -> array.
	
	@param [dictionary] d - The dictionary to convert.
	
	@public
	@returns [array] 
	
--]]

function Package.Utility.DictionaryToArray<a, b>(d: {[a]: b}): {[number]: {a | b}}?
	if not Package.Utility.IsDictionary(d) then
		Debugger.silenterror(`Field 'd' expected dictionary, got {typeof(d)}.`)
		return
	end
	
	local newArray = { }
	
	for key, value in d do
		table.insert(newArray, {key, value})
	end
	
	return newArray
end

--[[

	Converts a array -> dictionary
	
	@param [array] t - The array to convert.
	
	@public
	@returns [dictionary] 
	
--]]

function Package.Utility.ArrayToDictionary<a, b>(t: {[number]: {a | b}}): {[a]: b}?
	if Package.Utility.IsDictionary(t) then
		Debugger.silenterror(`Field 't' expected array, got {typeof(t)}.`)
		return
	end

	local newDictionary = { }

	for index, value in t do
		newDictionary[value[1]] = value[2]
	end
	
	return newDictionary
end

--[[

	Converts a array -> string. Example:
	
	```
	local myArray = {"This", "Is", "An", "Array!", 1, 2, 3, true, false}
	
	print(Utility.arrayToString(myArray))
	
	-- Output: {[1] = "This", [2] = "Is", [3] = "An", [4] = "Array!", [5] = 1, [6] = 2, [7] = 3, [8] = true, [9] = false}
	```
	
	@param [array] t - The array to convert.
	
	@public
	@returns [dictionary] 
	
--]]

function Package.Utility.ArrayToString(t: {[number]: any}, sep: string?, i: number?, j: number?): string?
	local stringToConvert = "{"
	
	sep = Package.Utility.nilparam(sep, ", ")
	i = Package.Utility.nilparam(i, 1)
	j = Package.Utility.nilparam(j, #t)
	
	if i <= 0 or i > #t then
		Debugger.silenterror(`Field 'i' must be greater than 0 and less than or equal to {#t}.`)
		return
	end
	
	if j <= 0 or j > #t then
		Debugger.silenterror(`Field 'j' must be greater than 0 and less than or equal to {#t}.`)
		return
	end
	
	for index = i :: number, j :: number do
		local value = t[index]
		if type(value) == "string" then
			value = `"{value}"`
		end
		if type(value) == "table" and not Package.Utility.IsDictionary(value) then
			value = Package.Utility.ArrayToString(value, sep)
		end
		if index == j then
			stringToConvert = `{stringToConvert}[{index}] = {value}}`
		else
			stringToConvert = `{stringToConvert}[{index}] = {value}{sep}`
		end
	end
	
	return stringToConvert
end

--[[

	Returns the number of keys inside of the provided
	dictionary.
	
	@param [dictionary] d - The dictionary to get the
	count of.
	
	@public
	@returns [number] 
	
--]]

function Package.Utility.DictionaryGetn(d: {[any]: any}): number
	local count = 0
	
	for key, value in pairs(d) do
		count += 1
	end
	
	return count
end

--[[

	Creates a new benchmark object that can be used
	for benchmarking code.
	
	@public
	@returns [BenchmarkObject] 
	
--]]

function Package.Benchmark.CreateBenchmark()
	local self = setmetatable({ }, {__index = BenchmarkMethods})
	
	self.IsCompleted = false
	self.Destroying = Signal.new() :: ScriptSignal<>
	self.StartTime = 0
	self.EndTime = 0
	
	return self
end

--[[

	Sets a function that can be ran `timesToRun` times,
	and will return the amount of time it took to run
	the functions.
	
	@public
	@returns [?number] 
	
--]]

function BenchmarkMethods:SetFunction(timesToRun: number, func: (timesRan: number) -> ()): number?
	if timesToRun <= 0 then
		Debugger.silenterror("Field 'timesToRun' must be greater than 0.")
		return
	end
	
	local result
	
	task.spawn(function()
		self.StartTime = os.clock()

		for index = 1, timesToRun do
			func(index)
		end
		
		result = self:Stop()
	end)
	
	return result
end

--[[

	Starts a benchmark, please note that when using
	BenchmarkObject:SetFunction() that it will sta-
	rt itself.
	
	@public
	@returns [void] 
	
--]]

function BenchmarkMethods:Start()
	self.StartTime = os.clock()
end

--[[

	Stops a benchmark, destroying it and returning
	the elapsed time.
	
	@public
	@returns [number] 
	
--]]

function BenchmarkMethods:Stop(): number
	self.IsCompleted = true
	self.EndTime = os.clock()
	
	local StoppedTime = self.EndTime - self.StartTime
	
	self:Destroy()
	
	return StoppedTime
end

--[[

	Gets the current time elapsed after starting
	the benchmark.
	
	@public
	@returns [?number] 
	
--]]

function BenchmarkMethods:GetCurrentTime(): number?
	if self.IsCompleted then
		Debugger.silenterror("Timer cannot be stopped to view current time.")
		return
	end
	
	return os.clock() - self.StartTime
end

--[[

	Destroys the benchmark, this is done autom-
	atically after BenchmarkObject:Stop() is c-
	alled.
	
	@public
	@returns [void] 
	
--]]

function BenchmarkMethods:Destroy()
	self.Destroying:Fire()
	table.clear(self)
	setmetatable(self, nil)
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

function CanaryEngineClient.CreateNetworkSignal(name: string): ClientNetworkSignal
	return BridgeNet2.ReferenceBridge(name)
end

--[[

	Creates a `NetworkSignal`, can be used in the other types of RunContexts.
	
	@public
	@returns [sNetworkSignal] Similar to a remote event, but server-sided.
	
--]]

function CanaryEngineServer.CreateNetworkSignal(name: string): ServerNetworkSignal
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
	Package.Utility.assertmulti(
		{package:GetAttribute("PackageId") ~= nil, "Package must have a valid 'PackageId'"},
		{package:GetAttribute("VersionNumber") ~= nil, "Package must have a valid 'VersionNumber'"},
		{package:GetAttribute("PackageId") ~= 0, "Cannot have a PackageId of zero."}
	)
	
	warnIfNotLatestVersion = Package.Utility.nilparam(warnIfNotLatestVersion, true)
	
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

if script.Parent:GetAttribute("CheckLatestVersion") then
	Package.GetLatestPackageVersionAsync(script.Parent, true)
end

return Package
