-- // Package

--[=[
	The parent of all classes.

	@class Debugger
]=]
local Debugger = { }

--[=[
	The callstack type.

	@type CallStack {Name: string, Source: string, DefinedLine: number}
	@within Debugger
]=]
type CallStack = {Name: string, Source: string, DefinedLine: number}

-- // Variables

local Runtime = require(script.Parent.Runtime)
local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

local Prefix = "[Debugger]:"
local ValidCallstackNames = {
	"EngineClient",
	"EngineServer",
	"EngineReplicated",
	"EngineReplicatedFirst",
	"EngineScripts",
}

-- // Functions

local function dictionaryLen(d: {[any]: any})
	return setmetatable(d, {
		__len = function(t)
			local count = 0
			for key, value in pairs(d) do
				count += 1
			end
			return count
		end,
	})
end

Debugger.CachedStackTraces = dictionaryLen({ })

local function GetAncestorsUntilParentFolder(instance: Instance): string
	local Ancestors = { }
	local OriginalInstance = instance
	local CompleteString = ""

	repeat
		instance = instance.Parent :: Instance
		table.insert(Ancestors, instance)
	until table.find(ValidCallstackNames, instance.Name) and instance:IsA("Folder")

	for index = #Ancestors, 1, -1 do
		local ancestor = Ancestors[index]

		if CompleteString == "" then
			CompleteString = ancestor.Name
			continue
		end

		CompleteString = `{CompleteString}.{ancestor.Name}`
	end
	
	return `{CompleteString}.{OriginalInstance.Name}`
end

--[=[
	The main debug handler, adds a prefix to logs sent out and respects logging settings.

	@param debugHandler (...T) -> () | (message: T, level: number) -> () -- The function to run on debug, for example `Debugger.Debug(print, "Hello, world!")`
	@param arguments {string} | string -- The contents to be passed to the function
	@param prefix string? -- The prefix to put in front of the debug
	@param respectDebugger boolean? -- Whether or not to respect the debugger, should always be true for correct use
]=]
function Debugger.Debug<T>(debugHandler: (...T) -> () | (message: T, level: number) -> (), arguments: {T} | T, prefix: string?, respectDebugger: boolean?)
	prefix = prefix or Prefix

	if respectDebugger == nil then
		respectDebugger = true
	end

	if not respectDebugger then
		if type(arguments) == "table" then
			debugHandler(prefix, table.unpack(arguments))
		else
			debugHandler(`{prefix} {arguments}`)
		end
		return
	end

	if (RuntimeContext.Studio and RuntimeSettings.StudioDebugEnabled) or RuntimeSettings.LiveGameDebugger then
		if type(arguments) == "table" then
			debugHandler(prefix, table.unpack(arguments))
		else
			debugHandler(`{prefix} {arguments}`)
		end
	end
end

--[=[
	Gets the call stack of any instance.

	@param instance Instance -- The instance to start at
	@param stackName string? -- The name of the stack, defaults to the stack number
	
	@return string
]=]
function Debugger.GetCallStack(instance: Instance, stackName: string?): {Name: string, Source: string, DefinedLine: number}
	stackName = stackName or `Stack{#Debugger.CachedStackTraces + 1}`
	
	local Source = GetAncestorsUntilParentFolder(instance)
	local DefinedLine = debug.traceback():split(":")
	
	local StackTable = { }
	
	StackTable.Name = stackName
	StackTable.Source = Source
	StackTable.DefinedLine = tonumber(DefinedLine[#DefinedLine]:gsub("\n", ""))
	
	Debugger.CachedStackTraces[stackName] = StackTable
	
	return StackTable
end

-- // Actions

return Debugger