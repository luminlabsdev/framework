-- // Package

--[=[
	The parent of all classes.

	@class Debugger
]=]
local Debugger = { }

-- // Variables

local Runtime = require(script.Parent.Runtime)
local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

local Prefix = "[Debugger]: "
local ValidCallstackNames = {
	"EngineClient",
	"EngineServer",
	"EngineReplicated",
	"EngineReplicatedFirst",
	"EngineScripts",
}

-- // Functions

local function GetAncestorsUntilParentFolder(instance: Instance): string
	local Ancestors = { }
	local CompleteString = ""

	repeat
		instance = instance.Parent
		table.insert(Ancestors, instance)
	until table.find(ValidCallstackNames, instance.Name) and instance:IsA("Folder")

	for index = #Ancestors, 1, -1 do
		local ancestor = Ancestors[index]

		if CompleteString == "" then
			CompleteString = ancestor.Name
			continue
		end

		if index == 1 then
			CompleteString = `{CompleteString}.{instance.Name}`
			return CompleteString
		end

		CompleteString = `{CompleteString}.{ancestor.Name}`
	end
end

--[=[
	The main debug handler, adds a prefix to logs sent out and respects logging settings.

	@param debugHandler (...string | string) -> () -- The function to run on debug, for example `Debugger.Debug(print, "Hello, world!")`
	@param arguments {string} | string -- The contents to be passed to the function
]=]
function Debugger.Debug(debugHandler: (...string | string) -> (), arguments: {string} | string)
	if (RuntimeContext.Studio and RuntimeSettings.StudioDebugEnabled) or RuntimeSettings.LiveGameDebugger then
		if type(arguments) == "table" then
			debugHandler(`{Prefix}{table.unpack(arguments)}`)
		else
			debugHandler(`{Prefix}{arguments}`)
		end
	end
end

--[=[
	Gets the call stack of any instance.

	@param instance Instance -- The instance to start at
	@return string
]=]
function Debugger.GetCallStack(instance: Instance): string
	return GetAncestorsUntilParentFolder(instance)
end

-- // Actions

return Debugger