--[=[
	The statistics class.

	@class Statistics
]=]
local Statistics = { }

--[=[
	Gets the number that is in the middle of the dataset, more info can be found [here](https://en.wikipedia.org/wiki/Median). Here's an example scenario:

	```lua
	local CollectedData = {6, 8, 3, 7, 9, 0, 4, 1}

	print(Statistics.GetMedian(CollectedData))
	-- Output: 8
	```

	@param numberList {number} -- The dataset to perform the action on.

	@return number
]=]
function Statistics.GetMedian(numberList: {number}): number
	local TotalNumbers = #numberList
	local IsTotalEven = TotalNumbers % 2 == 0

	if not IsTotalEven then
		return numberList[(TotalNumbers / 2) + 0.5]
	end

	local FirstMedian = numberList[TotalNumbers / 2]
	local SecondMedian = numberList[(TotalNumbers / 2) + 1]

	return (FirstMedian + SecondMedian) / 2
end

--[=[
	Gets the most common number in the dataset, more info can be found [here](https://en.wikipedia.org/wiki/Mean). Here's an example scenario:

	```lua
	local CoinsForPlayers = {651, 8801, 371, 79, 918, 0, 46, 183}

	print(Statistics.GetMean(CoinsForPlayers)) -- Get the average amount of coins each player has, keep in mind 8801 will skew the data.
	-- Output: 1381.125
	```

	@param numberList {number} -- The dataset to perform the action on.

	@return number
]=]
function Statistics.GetMean(numberList: {number}): number
	local Total = 0

	for index, number in numberList do
		Total += number
	end

	return Total / #numberList
end

--[=[
	Gets the number that occurs most in the provided dataset, nil if none or each number occurs the same amount of times. More info can be found [here](https://en.wikipedia.org/wiki/Mode_(statistics))

	@param numberList {number} -- The dataset to perform the action on.

	@return number?
]=]
function Statistics.GetMode(numberList: {number}): number?
	local CalculatedList = { }

	table.sort(numberList)

	for index, number in numberList do
		if not CalculatedList[number] then
			CalculatedList[number] = 1
			continue
		end

		CalculatedList[number] += 1
	end

	local SortedList = Utility.DictionaryToArray(CalculatedList)

	table.sort(SortedList, function(a, b)
		return a[2] > b[2]
	end)

	if SortedList[1][1] == 1 and CalculatedList[SortedList[1][1]] == 1 then
		return nil
	end

	return SortedList[1][1]
end

return Statistics