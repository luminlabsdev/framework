
-- // Package

local Package = {
	Utility = { };
	Benchmark = { };
	Statistics = { },
	Serialize = require(script.Vendor.BlueSerializer)
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

type ScriptSignal<T> = {
	Connect: (self: ScriptSignal<T>?, func: (data: {T}) -> ()) -> (ScriptConnection);
	Wait: (self: ScriptSignal<T>?) -> ({T});
	Once: (self: ScriptSignal<T>?, func: (data: {T}) -> ()) -> (ScriptConnection);
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
	Connect: (self: CustomScriptSignal, func: (data: {any}) -> ()) -> (ScriptConnection);
	Wait: (self: CustomScriptSignal) -> ({any});
	Once: (self: CustomScriptSignal, func: (data: {any}) -> ()) -> (ScriptConnection);
	Fire: (self: CustomScriptSignal, data: {any}? | any?) -> ();
	DisconnectAll: (self: CustomScriptSignal) -> ()
}

--[[

	A NetworkSignal is similar to a remote event, client-sided.
	
	@public
	@typedef [{
	Connect: (self: ClientNetworkSignal, func: (data: {any}) -> ()) -> (ScriptConnection);
	Once: (self: ClientNetworkSignal, func: (data: {any}) -> ()) -> (ScriptConnection);
	Wait: (self: ClientNetworkSignal) -> ({any});
	Fire: (self: ClientNetworkSignal, data: {any}?) -> ();
	}] NetworkSignal
	
--]]

export type ClientNetworkController = {
	Connect: (self: ClientNetworkController, func: (data: {any}) -> ()) -> (ScriptConnection);
	Once: (self: ClientNetworkController, func: (data: {any}) -> ()) -> (ScriptConnection);
	Wait: (self: ClientNetworkController) -> ({any});
	Fire: (self: ClientNetworkController, data: {any}? | any?) -> ();
}

--[[

	A NetworkSignal is similar to a remote event, server-sided.
	
	@public
	@typedef [{
	Connect: (self: ServerNetworkSignal, func: (sender: Player, data: {any}) -> ()) -> (ScriptConnection);
	Once: (self: ServerNetworkSignal, func: (sender: Player, data: {any}) -> ()) -> (ScriptConnection);
	Wait: (self: ServerNetworkSignal) -> (Player, {any});
	Fire: (self: ServerNetworkSignal, recipient: Player | {Player}, data: {any}?) -> ();
	}] NetworkSignal
	
--]]

export type ServerNetworkController = {
	Connect: (self: ServerNetworkController, func: (sender: Player, data: {any}) -> ()) -> (ScriptConnection);
	Once: (self: ServerNetworkController, func: (sender: Player, data: {any}) -> ()) -> (ScriptConnection);
	Wait: (self: ServerNetworkController) -> (Player, {any});
	Fire: (self: ServerNetworkController, recipient: Player | {Player}, data: {any}? | any?) -> ();
}

type table = {}

-- // Variables

local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

if not ReplicatedStorage:FindFirstChild("CanaryEngineFramework") then
	error("CanaryEngine must be parented to DataModel.ReplicatedStorage")
end

local CanaryEngine = ReplicatedStorage:WaitForChild("CanaryEngineFramework")
local Vendor = CanaryEngine.CanaryEngine.Vendor

local Startup = require(script.Startup)
local StartupTime = Startup.StartEngine()
local Debugger = require(script.Debugger)
local Runtime = require(script.Runtime) -- Get the RuntimeSettings, which are settings that are set during runtime

local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

--

local Signal = require(Vendor.Signal)
local BridgeNetWrapper = require(Vendor.BridgeNetWrapper)

Package.Runtime = {
	RuntimeSettings = RuntimeSettings;
	RuntimeContext = RuntimeContext;
}

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

function Package.Utility.assert<a>(assertion: a, msg: string, ...: any): a?
	if not (assertion) then
		error(string.format(msg, ...), 0)
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
	
	@param [{assertion | msg | formatString}] - Same as assert, but takes
	multiple values to cut down on function calls. Used in
	that order.
	
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
	@returns [void] 
	
--]]

function Package.Utility.assertmulti<a, b>(...: {a | b | {any}?})
	for index, value in {...} do
		if not value[1] then
			error(string.format(value[2], table.unpack(value[3])), 0)
		end
	end
end

--[[

	Deep copies the provided table. When deep copying, tables
	nested inside the provided table will be copied as well,
	where this usually isn't the case.
	
	@param [array] t - The array that should be deep copied.
	
	@public
	@returns [array?] 
	
--]]

function Package.Utility.DeepCopy<a>(t: {[number]: a}): {[number]: a}?
	local copied = { }

	if type(t) ~= "table" then
		Debugger.error(`Field 't' expected array, got {typeof(t)}.`)
		return nil
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

function Package.Utility.IsDictionary(t: table): boolean
	if type(t) ~= "table" then
		Debugger.error(`Field 't' expected table, got {typeof(t)}.`)
		return false
	end
	return not t[1]
end

--[[

	Converts a dictionary -> array.
	
	@param [dictionary] d - The dictionary to convert.
	
	@public
	@returns [array] 
	
--]]

function Package.Utility.DictionaryToArray<a, b>(d: {[a]: b}): {[number]: {a | b}}?
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
		Debugger.error(`Field 't' expected array, got {typeof(t)}.`)
		return
	end

	local newDictionary = { }

	for index, value in t do
		newDictionary[value[1]] = value[2]
	end

	return newDictionary
end

--[[

	Running this function on a dictionary will allow
	you to use the length operator (#dict) on it.
	
	@param [dictionary] d - The dictionary to set
	the metatable to.
	
	@public
	@returns [void]
	
--]]

function Package.Utility.dictionaryLen(d: {[any]: any})
	setmetatable(d, {
		__len = function(t)
			local count = 0
			for key, value in pairs(d) do
				count += 1
			end
			return count
		end,
	})
end

--[[

	Gets all of the ancestors of the provided
	instance.
	
	@param [Instance] instance - The instance
	to get all of the ancestors of.
	
	@public
	@returns [Instance]
	
--]]

function Package.Utility.GetAncestors(instance: Instance): {Instance}
	local ancestors = { }

	repeat
		instance = instance.Parent :: Instance
		table.insert(ancestors, instance)
	until instance == game

	table.remove(ancestors, table.find(ancestors, game))

	return ancestors
end

--[[

	Finds and waits for a child for whom
	Instance:IsA() will return true for.
	
	@param [Instance] instance - The pa-
	rent instance of the child to be fo-
	und.
	
	@param [string] className - The cla-
	ssName of the child to be found.
	
	@param [?number] timeOut - The amou-
	nt of time the instance should be
	waited for, nil if forever.
	
	@public
	@returns [Instance]
	
--]]

function Package.Utility.WaitForChildWhichIsA(instance: Instance, className: string, timeOut: number?)
	for index, value in instance:GetChildren() do
		if value:IsA(className) then
			return instance:WaitForChild(value, timeOut)
		end
	end
end

--[[

	Finds and waits for child that `clas-
	sName` is equal to the child's class-
	Name.
	
	@param [Instance] instance - The pa-
	rent instance of the child to be fo-
	und.
	
	@param [string] className - The cla-
	ssName of the child to be found.
	
	@param [?number] timeOut - The amou-
	nt of time the instance should be
	waited for, nil if forever.
	
	@public
	@returns [Instance]
	
--]]

function Package.Utility.WaitForChildOfClass(instance: Instance, className: string, timeOut: number?)
	for index, value in instance:GetChildren() do
		if value.ClassName == className then
			return instance:WaitForChild(value, timeOut)
		end
	end
end

--[[

	Iterates through a list of values and
	returns a boolean and a string. If t-
	he value is true, then a string will
	be returned with a list of values a-
	nd their order in the original list.
	The function is useful for times wh-
	en you only want 1 value to be used
	at a time. Example:
	
	```
	local MyValues = {true, true, false}
	
	print(Utility.ConflictingValues(MyValues))
	
	-- Output: true Conflicting Values: 1; 2
	```
	
	@param [array] values - A list of
	values to be checked.
	
	@param [?string] sep - The separ-
	ator between each conflicting va-
	lue index.
	
	@public
	@returns [(boolean, ?string)] 
	
--]]

function Package.Utility.ConflictingValues(values: {any}, sep: string?): (boolean, string?)
	local trueValues = { }

	sep = Package.Utility.nilparam(sep, "; ")

	for index, value in values do
		if value then
			table.insert(trueValues, index)
		end
	end

	if #trueValues ~= 1 then
		return true, `Conflicting Values: {table.concat(trueValues, sep)}`
	end

	return false, nil
end

--[[

	Converts a array/dictionary -> string. An empty table
	will result in the function returning: "{}". Example
	of function in use:
	
	```
	local myArray = {"This", "Is", "An", "Array!", 1, 2, 3, true, false}
	
	print(Utility.TableToString(myArray))
	
	-- Output: {[1] = "This", [2] = "Is", [3] = "An", [4] = "Array!", [5] = 1, [6] = 2, [7] = 3, [8] = true, [9] = false}
	```
	
	@param [table] t - The table to convert
	@param [?string] sep - The separator
	between each element.
	
	@param [?number] i - The index to start
	at. (only for arrays)
	
	@param [?number] j - The index to end
	at. (only for arrays)
	
	@public
	@returns [dictionary] 
	
--]]

function Package.Utility.TableToString(t: {[any]: any}, sep: string?, i: number?, j: number?): string?
	if Package.Utility.IsDictionary(t) then
		Package.Utility.dictionaryLen(t)
	end

	if #t == 0 then
		return "{}"
	end

	local stringToConvert = "{"

	sep = Package.Utility.nilparam(sep, ", ")
	i = Package.Utility.nilparam(i, 1)
	j = Package.Utility.nilparam(j, #t)

	if not Package.Utility.IsDictionary(t) then
		if i <= 0 or i > #t then
			Debugger.error(`Field 'i' must be greater than 0 and less than or equal to {#t}.`)
			return
		end

		if j <= 0 or j > #t then
			Debugger.error(`Field 'j' must be greater than 0 and less than or equal to {#t}.`)
			return
		end
	end

	if Package.Utility.IsDictionary(t) then
		local current = 0

		for key, value in t do
			current += 1
			if type(value) == "string" then
				value = `"{value}"`
			end
			if type(value) == "table" then
				value = Package.Utility.TableToString(value, sep)
			end
			if current == #t then
				stringToConvert = `{stringToConvert}["{key}"] = {value}}`
			else
				stringToConvert = `{stringToConvert}["{key}"] = {value}{sep}`
			end
		end

		return stringToConvert
	end

	for index = i :: number, j :: number do
		local value = t[index]
		if type(value) == "string" then
			value = `"{value}"`
		end
		if type(value) == "table" then
			value = Package.Utility.TableToString(value, sep)
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

	Creates a new benchmark object that can be used
	for benchmarking code.
	
	@public
	@returns [BenchmarkObject] 
	
--]]

function Package.Benchmark.CreateBenchmark()
	local self = setmetatable({ }, {__index = BenchmarkMethods})

	self.IsCompleted = false
	self.Destroying = Signal.new() :: ScriptSignal<nil>
	self.StartTime = 0
	self.EndTime = 0

	return self
end

--[[

	Sets a function that can be ran `timesToRun` times,
	and will return the amount of time it took to run
	the functions.
	
	@param [number] timesToRun - The amount of times to
	run the following function.
	
	@param [function] func - The function to run for e-
	ach `timesToRun` index.
	
	@public
	@returns [?number] 
	
--]]

function BenchmarkMethods:SetFunction(timesToRun: number, func: (timesRan: number) -> ()): number?
	if timesToRun <= 0 then
		Debugger.error("Field 'timesToRun' must be greater than 0.")
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
		Debugger.warn("Benchmark timer must still be running to view the current time.")
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

	Gets the number in the middle of a dataset. For ex-
	ample, the median in the following dataset is 7:
	
	{2, 5, 6, 8, 3, 8}
	
	@param [array] numberList - The dataset of numbers
	to perform the function on.
	
	@public
	@returns [?number] 
	
--]]

function Package.Statistics.GetMedian(numberList: {number}): number
	local TotalNumbers = #numberList
	local IsTotalEven = TotalNumbers % 2 == 0
	
	if not IsTotalEven then
		return numberList[(TotalNumbers / 2) + 0.5]
	end
	
	local FirstMedian = numberList[TotalNumbers / 2]
	local SecondMedian = numberList[(TotalNumbers / 2) + 1]
	
	return (FirstMedian + SecondMedian) / 2
end

--[[

	Gets the average/mean of all of the numbers.
	
	@param [array] numberList - The dataset of numbers
	to perform the function on.
	
	@public
	@returns [?number] 
	
--]]

function Package.Statistics.GetMean(numberList: {number}): number
	local Total = 0
	
	for index, number in numberList do
		Total += number
	end
	
	return Total / #numberList
end

--[[

	Gets the mode of a list, nil if none. A mode
	in a dataset is a number that occurs the most.
	If all numbers occur the same amount of times,
	then the mode is null/nil. For example, the
	mode of this dataset is 5:
	
	{5, 5, 5, 7, 7, 3, 1}
	
	@param [array] numberList - The dataset of numbers
	to perform the function on.
	
	@public
	@returns [?number] 
	
--]]

function Package.Statistics.GetMode(numberList: {number}): number?
	local CalculatedList = { }
	
	table.sort(numberList)
	
	for index, number in numberList do
		if not CalculatedList[number] then
			CalculatedList[number] = 1
			continue
		end
		
		CalculatedList[number] += 1
	end
	
	local SortedList = Package.Utility.DictionaryToArray(CalculatedList)
	
	table.sort(SortedList, function(a, b)
		return a[2] > b[2]
	end)
	
	if SortedList[1][1] == 1 and CalculatedList[SortedList[1][1]] == 1 then
		return nil
	end
	
	return SortedList[1][1]
end

--[[

	Allows you to use the server sided version of cEngine.
	
	@public
	@returns [dictionary] EngineServer
	
--]]

function Package.GetEngineServer()
	if RuntimeContext.Server then
		CanaryEngineServer.Packages = {
			Server = ServerStorage:WaitForChild("EngineServer").Packages :: typeof(script.Parent.Packages.Server);
			Replicated = ReplicatedStorage:WaitForChild("EngineReplicated").Packages :: typeof(script.Parent.Packages.Replicated);
		}
		CanaryEngineServer.Media = ServerStorage:WaitForChild("EngineServer").Media :: typeof(CanaryEngine.Media.Server)

		return CanaryEngineServer
	else
		Debugger.error("Failed to fetch 'EngineServer'; Context must be server.")
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
			Client = ReplicatedStorage:WaitForChild("EngineClient").Packages :: typeof(script.Parent.Packages.Client);
			Replicated = ReplicatedStorage:WaitForChild("EngineReplicated").Packages :: typeof(script.Parent.Packages.Replicated);
		}
		CanaryEngineClient.Media = ReplicatedStorage:WaitForChild("EngineClient").Media :: typeof(CanaryEngine.Media.Client);
		CanaryEngineClient.Player = PlayerService.LocalPlayer :: Player
		CanaryEngineClient.PlayerGui = PlayerService.LocalPlayer:WaitForChild("PlayerGui") :: typeof(game:GetService("StarterGui"))

		return CanaryEngineClient
	else
		Debugger.error("Failed to fetch 'EngineClient'; Context must be client.")
	end
end

--[[

	Creates a `NetworkSignal`, can be used in the other types of RunContexts.
	
	@public
	@returns [ClientNetworkSignal] Similar to a remote event, but client-sided.
	
--]]

function CanaryEngineClient.CreateNetworkSignal<a>(name: a): ClientNetworkController
	return BridgeNetWrapper.newClient(name)
end

--[[

	Creates a `NetworkSignal`, can be used in the other types of RunContexts.
	
	@public
	@returns [ServerNetworkSignal] Similar to a remote event, but server-sided.
	
--]]

function CanaryEngineServer.CreateNetworkSignal<a>(name: a): ServerNetworkController
	return BridgeNetWrapper.newServer(name)
end

--[[

	Retrieves the main data service.
	
	@public
	@returns [dictionary] DataService
	
--]]

function CanaryEngineServer.GetDataService()
	return require(Vendor.DataService)
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
	
	@param [Instance] package - The package to check the version of,
	must have a `VersionNumber` and `PackageId` attribute, and the asset
	must have a 'Version: (number)' in its description.
	
	@param [?boolean] warnIfNotLatestVersion - An option to log a warning
	if the package version isn't the latest.
	
	@public
	
	@returns [?number] The fetched version, may be nil if there was an
	error fetching the version
	
--]]

function Package.GetLatestPackageVersionAsync(package: Instance, warnIfNotLatestVersion: boolean?, respectDebugger: boolean?): number?
	Package.Utility.assertmulti(
		{package:GetAttribute("PackageId") ~= nil, "Package must have a valid 'PackageId'"},
		{package:GetAttribute("VersionNumber") ~= nil, "Package must have a valid 'VersionNumber'"},
		{package:GetAttribute("PackageId") ~= 0, "Cannot have a PackageId of zero."},
		{package:GetAttribute("CheckLatestVersion") ~= nil, "Package must include 'CheckLatestVersion' setting."}
	)
	
	if not package:GetAttribute("CheckLatestVersion") then
		return nil
	end

	warnIfNotLatestVersion = Package.Utility.nilparam(warnIfNotLatestVersion, true)
	respectDebugger = Package.Utility.nilparam(respectDebugger, true)

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

Package.GetLatestPackageVersionAsync(script.Parent)

return Package
