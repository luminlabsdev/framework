-- // Benchmark

--[=[
	The parent of all classes.

	@class Benchmark
]=]
local Benchmark = { }

--[=[
	The benchmark object itself.

	@class BenchmarkObject
]=]

--[=[
	A boolean to decide if the benchmark should be GC'ed.

	@prop IsCompleted boolean
	@within BenchmarkObject
]=]

--[=[
	A signal that fires when the benchmark has been disposed of.

	@prop Destroying ScriptSignal
	@tag Event
	@within BenchmarkObject
]=]

--[=[
	The time (in seconds) the benchmark was started at.

	@prop StartTime number
	@within BenchmarkObject
]=]

--[=[
	The time (in seconds) the benchmark was ended at.

	@prop EndTime number
	@within BenchmarkObject
]=]

-- // Types

--[=[
	The data that is returned after a `:SetFunction` call is finished.

	@type BenchmarkData {total: number, longest: number, shortest: number, average: number}
	@within Benchmark
]=]
type BenchmarkData = {Total: number, Longest: number, Shortest: number, Average: number}

-- // Variables

local BenchmarkObject = { }

local Statistics = require(script.Parent.Statistics)
local Debugger = require(script.Parent.Parent.Debugger)
local Signal = require(script.Parent.Parent.Controllers.Vendor.SignalController)

-- // Functions

--[=[
	Creates a new Benchmark object to be used.

	@return BenchmarkObject
]=]
function Benchmark.CreateBenchmark()
	local self = setmetatable({ }, {__index = BenchmarkObject})

	self.IsCompleted = false
	self.Destroying = Signal.NewController("Destroying")
	self.StartTime = 0
	self.EndTime = 0

	return self
end

--[=[
	Sets the function to be ran `timesToRun` amount of times. 

	:::danger

	`BenchmarkObject:Stop` is already called after being finished, calling the latter manually will result in an error.

	:::
	
	@param timesToRun number -- The amount of times to run `func`.
	@param func (timesRan: number) -> () -- The function to run for each `timesToRun` index, has a `timesRan` argument which is how many times the benchmark has run so far.

	@return BenchmarkData
]=]
function BenchmarkObject:SetFunction(timesToRun: number, func: (timesRan: number) -> ()): BenchmarkData
	if timesToRun <= 0 then
		Debugger.error("Field 'timesToRun' must be greater than 0.")
		return
	end

	local CollectedBenchmarkData = { }
	self.StartTime = os.clock()

	for index = 1, timesToRun do
		func(index)
		table.insert(CollectedBenchmarkData, os.clock() - self.StartTime)
	end

	return {
		Total = self:Stop(),
		Average = Statistics.GetMean(CollectedBenchmarkData),
		Shortest = math.min(table.unpack(CollectedBenchmarkData)),
		Longest = math.max(table.unpack(CollectedBenchmarkData)),
	}
end

--[=[
	Takes some [BenchmarkData] and formats it nicely in the output without a hassle.

	@param benchmarkData BenchmarkData -- The benchmark data to base off of
]=]
function BenchmarkObject:PrintBenchmark(benchmarkData: BenchmarkData)
	for dataType, metric in benchmarkData do
		print(`{dataType}: {metric * 1000}ms`)
	end
end

--[=[
	Starts the benchmark object.

	@deprecated v3.2.4 -- Use :SetFunction instead.
]=]
function BenchmarkObject:Start()
	self.StartTime = os.clock()
end

--[=[
	Stops the benchmark from running and destroys it, returns the amount of time it took to complete the code above it.

	@return number
]=]
function BenchmarkObject:Stop(): number
	self.IsCompleted = true
	self.EndTime = os.clock()

	local StoppedTime = self.EndTime - self.StartTime

	self:Destroy()

	return StoppedTime
end

--[=[
	Gets the current elapsed time of the benchmark.

	@return number?
]=]
function BenchmarkObject:GetCurrentTime(): number?
	if self.IsCompleted then
		Debugger.warn("Benchmark timer must still be running to view the current time.")
		return
	end

	return os.clock() - self.StartTime
end

--[=[
	Destroys the `BenchmarkObject`, this is done automatically after `SetFunction` is finished of `Stop` is called.
]=]
function BenchmarkObject:Destroy()
	self.Destroying:Fire()
	table.clear(self)
	setmetatable(self, nil)
end

-- // Actions

return Benchmark