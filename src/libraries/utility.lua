--[=[
	The Utility class.

	@class Utility
]=]
local Utility = { }

local HttpService = game:GetService("HttpService")
local PlayerService = game:GetService("Players")
local Debugger = require(script.Parent.Parent.Debugger)
local Types = require(script.Parent.Parent.Parent.Types)

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
	Generates a unique identifier that will not be the same of any others. Short for **U**niversally **U**nique **ID**entifier
	[UUID Wikipedia](https://en.wikipedia.org/wiki/Universally_unique_identifier)

	@return string
]=]
function Utility.GenerateUUID(): string
	return HttpService:GenerateGUID(false):gsub("-", "")
end

--[=[
	Returns a table of all of the players that are in a specified range from `comparePoint`.

	@param comparePoint Vector3 -- The point to which should be compared from, can be a parts position for example
	@param maximumRange number -- The maximum range of which to get players from the `comparePoint`

	@return {Player}
]=]
function Utility.GetPlayersInRange(comparePoint: Vector3, maximumRange: number): {Player}
	local PlayersToReturn = { }
	
	for _, player: Player in PlayerService:GetPlayers() do
		if player:DistanceFromCharacter(comparePoint) <= maximumRange then
			table.insert(PlayersToReturn, player)
		end
	end

	return PlayersToReturn
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

return Utility