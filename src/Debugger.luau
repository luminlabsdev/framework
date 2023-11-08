--!strict

-- // Package

local Debugger = { }

-- // Types

type CallStack = {Source: string, SourceTree: {Instance}, DefinedLine: number}

-- // Variables

local HttpService = game:GetService("HttpService")

local Runtime = require(script.Parent.Runtime)

local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

local Prefix = "[Debug]"

-- // Functions

Debugger.CachedLogs = { }

local function ReverseTable<T>(t: {[number]: T}): {[number]: T}
	local NewTable = { }

	for index, value in t do
		table.insert(NewTable, #t - index + 1, value)
	end
	
	return NewTable
end

local function GetAncestorsUntilParentFolder(instance: Instance): {Instance}
	local Ancestors = { }

	repeat
		instance = instance.Parent :: Instance
		table.insert(Ancestors, instance)
	until instance.Parent == game
	
	return ReverseTable(Ancestors)
end

-- You're not meant to debug errors as they stop the thread, which could lead to major codebase issues
function Debugger.Debug<T...>(debugHandler: (prefix: string, T...) -> (), ...: T...)
	if (RuntimeContext.Studio and RuntimeSettings.StudioDebugging) or RuntimeSettings.LiveGameDebugging then
		debugHandler(Prefix, ...)
	end
end

function Debugger.DebugPrefix<T...>(debugHandler: (prefix: string, T...) -> (), prefix: string, ...: T...)
	if (RuntimeContext.Studio and RuntimeSettings.StudioDebugging) or RuntimeSettings.LiveGameDebugging then
		debugHandler(prefix, ...)
	end
end

function Debugger.GetCallStack(instance: LuaSourceContainer): CallStack
	assert(instance:IsA("LuaSourceContainer"), "Instance must be a lua source container")

	local StackFunction = debug.info(2, "n")

	return {
		Source = `{instance:GetFullName()}{if StackFunction and StackFunction ~= "" then string.format(" @ %s", StackFunction) else ""}`,
		SourceTree = GetAncestorsUntilParentFolder(instance),
		DefinedLine = debug.info(2, "l"),
	}
end

function Debugger.LogEvent(instance: LuaSourceContainer, eventName: string)
	if not (RuntimeContext.Studio and RuntimeSettings.ShowLoggedEvents) then
		return
	end

	assert(instance:IsA("LuaSourceContainer"), "Instance must be a lua source container")

	if not Debugger.CachedLogs[instance] then
		Debugger.CachedLogs[instance] = { }
	end

	table.insert(Debugger.CachedLogs[instance], eventName)
	Debugger.DebugPrefix(print, "[Log]", eventName)
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