-- // Package

local Benchmark = { }

-- // Types

type BenchmarkData = {Total: number, Longest: number, Shortest: number, Average: number}

-- // Variables

local BenchmarkObject = { }
local ToString = {
	__tostring = function(table)
		local ConvertedString = ""

		for dataType, metric in table do
			ConvertedString = `{ConvertedString}\n\t{dataType}: {metric * 1000}ms`
		end

		return ConvertedString
	end
}

local Signal = require(script.Signal)
local Statistics = require(script.Statistics)

-- // Functions

function Benchmark.CreateBenchmark()
	local self = setmetatable({ }, {__index = BenchmarkObject})

	self.IsCompleted = false
	self.Destroying = Signal()
	self.StartTime = 0
	self.EndTime = 0

	return self
end

function BenchmarkObject:SetFunction(timesToRun: number, func: (timesRan: number) -> ()): BenchmarkData
	if timesToRun <= 0 then
		error("Field 'timesToRun' must be greater than 0.", 0)
	end

	local CollectedBenchmarkData = { }
	self.StartTime = os.clock()

	for index = 1, timesToRun do
		func(index)
		table.insert(CollectedBenchmarkData, os.clock() - self.StartTime)
	end

	if timesToRun >= 8000 then
		return setmetatable({
			Total = self:Stop(),
			Average = Statistics.GetMean(CollectedBenchmarkData),
			Shortest = 0,
			Longest = 0,
		}, ToString)
	end

	return setmetatable({
		Total = self:Stop(),
		Average = Statistics.GetMean(CollectedBenchmarkData),
		Shortest = math.min(table.unpack(CollectedBenchmarkData)),
		Longest = math.max(table.unpack(CollectedBenchmarkData)),
	}, ToString)
end

function BenchmarkObject:Start()
	self.StartTime = os.clock()
end

function BenchmarkObject:Stop(): number
	self.IsCompleted = true
	self.EndTime = os.clock()

	local StoppedTime = self.EndTime - self.StartTime

	self:Destroy()

	return StoppedTime
end

function BenchmarkObject:GetCurrentTime(): number?
	if self.IsCompleted then
		warn("Benchmark timer must still be running to view the current time.")
		return
	end

	return os.clock() - self.StartTime
end

function BenchmarkObject:Destroy()
	self.Destroying:Fire()
	self.Destroying:DisconnectAll()
	
	table.clear(self)
	setmetatable(self, nil)
end

-- // Connections

-- // Actions

return Benchmark