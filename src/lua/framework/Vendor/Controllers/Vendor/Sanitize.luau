return function(data: any?): {any}
	if data == nil then
		return { }
	end
	
	if type(data) ~= "table" then
		return {data}
	end
	
	return data
end