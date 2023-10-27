-- // Package

local Debugger = { }
local Libraries = script.Parent.Libraries

-- // Types

type CallStack = {Name: string, Source: string, DefinedLine: number}

-- // Variables

local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")

local Guard = require(Libraries.RedbloxUtils.Guard)
local Runtime = require(script.Parent.Runtime)

local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

local Prefix = "[Debug]"

local ValidCallstackNames = {
	"Client",
	"Server",
	"Shared",
	"ReplicatedFirst",
}

-- // Functions

local function PackArgs(...: any)
	return {...}
end

Debugger.CachedDebugCalls = { }
Debugger.CachedLogs = { }
Debugger.InternalCachedLogs = { }

local function GetAncestorsUntilParentFolder(instance: Instance): {string | {Instance}}
	local Ancestors = { }
	local OriginalInstance = instance
	local CompleteString = ""

	repeat
		instance = instance.Parent :: Instance
		table.insert(Ancestors, instance)
	until table.find(ValidCallstackNames, instance.Name) and instance:IsA("Folder")

	for _, ancestor in Ancestors do
		if CompleteString == "" then
			CompleteString = ancestor.Name
			continue
		end

		CompleteString = `{ancestor.Name}.{CompleteString}`
	end
	
	return {
		`{CompleteString}.{OriginalInstance.Name}`,
		Ancestors,
	}
end

-- You're not meant to debug errors as they stop the thread, which could lead to major codebase issues
function Debugger.Debug<T...>(debugHandler: (prefix: string, T...) -> (), ...: T...)
	table.insert(Debugger.CachedDebugCalls, PackArgs(...))

	if (RuntimeContext.Studio and RuntimeSettings.StudioDebugEnabled) or RuntimeSettings.LiveGameDebugEnabled then
		debugHandler(Prefix, ...)
	end
end

function Debugger.DebugPrefix<T...>(debugHandler: (prefix: string, T...) -> (), prefix: string, ...: T...)
	table.insert(Debugger.CachedDebugCalls, PackArgs(...))

	if (RuntimeContext.Studio and RuntimeSettings.StudioDebugEnabled) or RuntimeSettings.LiveGameDebugEnabled then
		debugHandler(prefix, ...)
	end
end

function Debugger.ClearOutput(clearDebugCallCache: boolean?)
	if clearDebugCallCache then
		table.clear(Debugger.CachedDebugCalls)
	end

	LogService:ClearOutput()
end

function Debugger.Assert<T>(assertionHandler: (...any) -> (), assertion: T, message: string, ...: string): T
	if not assertion then
		Debugger.Debug(assertionHandler, string.format(message, ...))
	end
	return assertion
end

function Debugger.GetCallStack(instance: LuaSourceContainer, stackName: string?): CallStack
	instance = Guard.Instance(instance)
	
	local Source = GetAncestorsUntilParentFolder(instance)
	local DefinedLine = debug.traceback():split(":")
	
	local StackTable = { }
	
	StackTable.Name = stackName
	StackTable.Source = Source[1]
	StackTable.SourceTree = Source[2]
	StackTable.DefinedLine = tonumber(DefinedLine[#DefinedLine]:gsub("\n", ""), nil)
	
	return StackTable
end

function Debugger.LogEvent(instance: LuaSourceContainer, eventName: string, silent: boolean?)
	if not Debugger.CachedLogs[instance] then
		Debugger.CachedLogs[instance] = { }
	end

	table.insert(Debugger.CachedLogs[instance], eventName)
	
	if not silent then
		Debugger.DebugPrefix(print, "[Log]", eventName)
	end
end

function Debugger.GenerateUUID()
	return string.gsub(
		HttpService:GenerateGUID(false),
		"-",
		""
	)
end

-- // Actions

return table.freeze(Debugger)