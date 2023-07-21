--[=[
	The parent of all classes.

	@class Controllers
]=]
local Controllers = { }

-- // Variables

-- // Functions

--[=[
	Sanitizes data sent through `:Fire` methods.

	@private

	@param data any -- The data to sanitize
	@return {any}?
]=]
function Controllers.SanitizeData(data: any): {any}?
	if type(data) ~= "table" and data ~= nil then
		return {data}
	end
	
	return data
end

-- // Actions

return Controllers