return function(data: any?): {any}?
	if type(data) ~= "table" and data ~= nil then
		return {data}
	end
	
	return data
end