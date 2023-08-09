--[=[
	The Utility class.

	@class Utility
]=]
local Utility = { }
local Debugger = require(script.Parent.Parent.Debugger)

--[=[
	Checks if `param` is nil, and if it is, it will return the provided `default` value.

	@param param T? -- The param to check the value of.
	@param default T -- The default value to be provided if `param` is nil.

	@return T
]=]
function Utility.nilparam<T>(param: T?, default: T): T
	if param == nil then
		return default
	else
		return param
	end
end

--[=[
	Basically just [assert](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#assert), but more performant.

	@param assertion T -- The param to check the value of.
	@param msg string -- The error message to throw if `assertion` is not truthy.
	@param ... any -- Data to format in `msg`.

	@return T?
]=]
function Utility.assert<T>(assertion: T, msg: string, ...: any): T?
	if not (assertion) then
		error(string.format(msg, ...), 0)
		return nil
	end

	return assertion
end

--[=[
	Basically just [assert](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#assert) and [xpcall](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#xpcall) combined.

	@param assertion T -- The param to check the value of.
	@param handler () -> () -- The function to run if `assertion` is not truthy.

	@return T?
]=]
function Utility.xassert<T>(assertion: T, handler: () -> ())
	if not (assertion) then
		handler()
	end
end

--[=[
	Basically just [assert](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#assert) but can handle multple assertions in one function, cutting down on calls and wasted resources.

	@param ... {a | b| {any}?} -- The assertion parameters, parameters are in same order as `Utility.assert`.

	@return T?
]=]
function Utility.assertmulti<a, b>(...: {a | b | {any}?})
	for index, value in {...} do
		if not value[1] then
			error(string.format(value[2], table.unpack(value[3])), 0)
		end
	end
end

--[=[
	Since [table.clone](https://create.roblox.com/docs/reference/engine/libraries/table#table.clone) does not copy tables nested deeper then its parent, we created a function to deep copy tables which copies all tables nested inside it as well as the parent table.

	@param t {a} -- The table to deep copy. Can be a dictionary or an array.

	@return {a}
]=]
function Utility.DeepCopy<a>(t: {a}): {a}
	local copied = { }

	for index, value in t do
		if type(value) == "table" then
			value = Utility.DeepCopy(value)
		end
		copied[index] = value
	end

	return copied
end

--[=[
	Tells whether the provided table, `t`, is a dictionary or not. True if yes, and vice versa.

	@param t {any} -- The table to check the type of.

	@return boolean
]=]
function Utility.IsDictionary(t: {any}): boolean
	if type(t) ~= "table" then
		Debugger.Debug(error, `Field 't' expected table, got {typeof(t)}.`)
		return false
	end
	return not t[1]
end

--[=[
	Converts a dictionary to an array, can be useful for when cutting down on data costs. It essentially serializes a dictionary.

	@param d {[a]: b} -- The dictionary to convert.

	@return {{a | b}}?
]=]
function Utility.DictionaryToArray<a, b>(d: {[a]: b}): {{a | b}}?
	local newArray = { }

	for key, value in d do
		table.insert(newArray, {key, value})
	end

	return newArray
end

--[=[
	Converts an array to a dictionary, this is basically the deserializer for `Utility.DictionaryToArray`.

	@param t {{a | b}} -- The array to convert.

	@return {[a]: b}?
]=]
function Utility.ArrayToDictionary<a, b>(t: {[number]: {a | b}}): {[a]: b}?
	if Utility.IsDictionary(t) then
		Debugger.Debug(error, `Field 't' expected array, got {typeof(t)}.`)
		return
	end

	local newDictionary = { }

	for index, value in t do
		newDictionary[value[1]] = value[2]
	end

	return newDictionary
end

--[=[
	Running this function on a dictionary allows you to use the length (#) operator on dictionaries. [Length operator](https://create.roblox.com/docs/luau/operators#miscellaneous)

	@param d {[any]: any} -- The dictionary to set the metamethod to.
]=]
function Utility.dictionaryLen(d: {[any]: any})
	if not Utility.IsDictionary(d) then
		Debugger.Debug(error, "Field 'd' must be a dictionary.")
	end
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

--[=[
	Returns every ancestor of `instance`, excluding the [DataModel](https://create.roblox.com/docs/projects/data-model)

	@param instance Instance -- The instance to get the ancestors of.

	@return {Instance}
]=]
function Utility.GetAncestors(instance: Instance): {Instance}
	local ancestors = { }

	repeat
		instance = instance.Parent :: Instance
		table.insert(ancestors, instance)
	until instance == game

	table.remove(ancestors, table.find(ancestors, game))

	return ancestors
end

--[=[
	Basically [Instance:WaitForChild] and [Instance:FindFirstChildWhichIsA] combined.

	@param instance Instance -- The instance to perform the function on.
	@param className string -- The [Instance.ClassName] to look for, uses [Instance:IsA].
	@param timeOut number? -- The amount of time to wait until the child request is timed out. 

	@return Instance
]=]
function Utility.WaitForChildWhichIsA(instance: Instance, className: string, timeOut: number?): Instance
	for index, value in instance:GetChildren() do
		if value:IsA(className) then
			return instance:WaitForChild(value, timeOut)
		end
	end
end

--[=[
	Basically [Instance:WaitForChild] and [Instance:FindFirstChildOfClass] combined.

	@param instance Instance -- The instance to perform the function on.
	@param className string -- The [Instance.ClassName] to look for.
	@param timeOut number? -- The amount of time to wait until the child request is timed out. 

	@return Instance
]=]
function Utility.WaitForChildOfClass(instance: Instance, className: string, timeOut: number?): Instance
	for index, value in instance:GetChildren() do
		if value.ClassName == className then
			return instance:WaitForChild(value, timeOut)
		end
	end
end

--[=[
	Iterates through a list of values and returns a boolean and a string. If the value is true, then a string will be returned with a list of values and their order in the original list. The function is useful for times when you only want 1 value to be used at a time. **Example:**
	
	```lua
	local MyValues = {true, true, false}
	
	print(Utility.ConflictingValues(MyValues))
	
	-- Output: true Conflicting Values: 1, 2
	```

	@param values {any} -- The list of values to be checked.
	@param sep string? -- If values are conflicting with each other, an error of the indexes are thrown and this is the separator between each one.

	@return (boolean, string?)
]=]
function Utility.ConflictingValues(values: {any}, sep: string?): (boolean, string?)
	local trueValues = { }

	sep = Utility.nilparam(sep, ", ")

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

--[=[
	Converts a table to a string, useful for displaying tables on GUI's. This is compatible with nested tables, dictionaries, and arrays. Example:

	```lua
	local MyTable = {"This table", "was converted into", 1, "string", "!"}

	print(Utility.TableToString(MyTable, ", "))
	-- Output: {[1] = "This table", [2] = "was converted into", [3] = 1, [4] = "string", [5] = "!"}
	```

	@param t {[any]: any} -- The table to convert to a string.
	@param sep string? -- The separator between each key + value
	@param i number? -- The index to start at. (only applies to arrays)
	@param j number? -- The index to end at. (only applies to arrays)

	@return string?
]=]
function Utility.TableToString(t: {[any]: any}, sep: string?, i: number?, j: number?): string?
	if Utility.IsDictionary(t) then
		Utility.dictionaryLen(t)
	end

	if #t == 0 then
		return "{}"
	end

	local stringToConvert = "{"

	sep = Utility.nilparam(sep, ", ")
	i = Utility.nilparam(i, 1)
	j = Utility.nilparam(j, #t)

	if not Utility.IsDictionary(t) then
		if i <= 0 or i > #t then
			Debugger.Debug(error, `Field 'i' must be greater than 0 and less than or equal to {#t}.`)
			return
		end

		if j <= 0 or j > #t then
			Debugger.Debug(error, `Field 'j' must be greater than 0 and less than or equal to {#t}.`)
			return
		end
	end

	if Utility.IsDictionary(t) then
		local current = 0

		for key, value in t do
			current += 1
			if type(value) == "string" then
				value = `"{value}"`
			end
			if type(value) == "table" then
				value = Utility.TableToString(value, sep)
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
			value = Utility.TableToString(value, sep)
		end
		if index == j then
			stringToConvert = `{stringToConvert}[{index}] = {value}}`
		else
			stringToConvert = `{stringToConvert}[{index}] = {value}{sep}`
		end
	end

	return stringToConvert
end


return Utility