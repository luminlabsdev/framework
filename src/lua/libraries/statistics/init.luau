local Statistics = { }

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

function Statistics.GetMean(numberList: {number}): number
	local Total = 0

	for _, number in numberList do
		Total += number
	end

	return Total / #numberList
end

function Statistics.GetMode(numberList: {number}): number?
	print("deprecated")
end

return Statistics