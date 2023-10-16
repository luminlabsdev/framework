-- // Package

local EngineDebugger = { }

type CallStack = {Name: string, Source: string, DefinedLine: number}
export type ExpectedType = "Axes" | "BrickColor" | "CatalogSearchParams" | "CFrame" | "Color3" | "ColorSequence" | "ColorSequenceKeypoint" | "Content" | "DateTime"
| "DockWidgetPluginGuiInfo" | "Enum" | "EnumItem" | "Enums" | "Faces" | "FloatCurveKey" | "Font" | "Instance" | "NumberRange" | "NumberSequence"
| "NumberSequenceKeyPoint" | "OverlapParams" | "PathWaypoint" | "PhysicalProperties" | "Random" | "Ray" | "RayastParams" | "RaycastResult" | "RBXScriptConnection"
| "RBXScriptSignal" | "Rect" | "Region3" | "Region3int16" | "SharedTable" | "TweenInfo" | "UDim" | "UDim2" | "Vector2" | "Vector2int16" | "Vector3" | "Vector3int16"
| "nil" | "boolean" | "number" | "string" | "function" | "userdata" | "thread" | "table"

-- // Variables

local EngineVendor = script.Parent
local EngineLibraries = EngineVendor.Libraries

local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")

local Runtime = require(EngineVendor.Runtime)
local Guard = require(EngineLibraries.RedbloxUtils.Guard)
local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

local Prefix = "[Debug]"
local ErrorPrefix = "[Debug:Critical]"
local WarnPrefix = "[Debug:Issue]"

local ValidCallstackNames = {
	"EngineClient",
	"EngineServer",
	"EngineReplicated",
	"EngineReplicatedFirst",
}

-- // Functions

local function PackArgs(...: any)
	return {...}
end

EngineDebugger.CachedDebugCalls = { }
EngineDebugger.CachedLogs = { }
EngineDebugger.InternalCachedLogs = { }

EngineDebugger.Handlers = {
	Error = function(...)
		error(
			`{ErrorPrefix} {
				table.concat(PackArgs(...), " ")
			}`,
			0
		) -- may cause weird stack stuff
	end,

	Log = function(...)
		print("[Event]:", ...)
	end,

	Print = function(...)
		print(Prefix, ...)
	end,

	Warn = function(...)
		warn(WarnPrefix, ...)
	end
}

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

function EngineDebugger.Debug<T...>(debugHandler: (T...) -> (), ...: T...)
	table.insert(EngineDebugger.CachedDebugCalls, PackArgs(...))

	if (RuntimeContext.Studio and RuntimeSettings.StudioDebugEnabled) or RuntimeSettings.LiveGameDebugEnabled then
		debugHandler(...)
	end
end

function EngineDebugger.ClearOutput(clearDebugCallCache: boolean?)
	if clearDebugCallCache then
		table.clear(EngineDebugger.CachedDebugCalls)
	end

	LogService:ClearOutput()
end

function EngineDebugger.Assert<T>(assertionHandler: (...any) -> (), assertion: T, message: string, ...: string): T
	if not assertion then
		EngineDebugger.Debug(assertionHandler, string.format(message, ...))
	end
	return assertion
end

function EngineDebugger.GetCallStack(instance: LuaSourceContainer, stackName: string?): CallStack
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

function EngineDebugger.LogEvent(instance: LuaSourceContainer, eventName: string, printLog: boolean?, isInternal: boolean?)
	if printLog == nil then
		printLog = true
	end
	
	if not EngineDebugger.CachedLogs[instance] and not isInternal then
		EngineDebugger.CachedLogs[instance] = { }
	end

	if not EngineDebugger.InternalCachedLogs[instance] and isInternal then
		EngineDebugger.InternalCachedLogs[instance] = { }
	end

	if isInternal then
		table.insert(EngineDebugger.InternalCachedLogs[instance], eventName)
	else
		table.insert(EngineDebugger.CachedLogs[instance], eventName)
	end

	if printLog then
		EngineDebugger.Debug(EngineDebugger.Handlers.Log, eventName)
	end
end

function EngineDebugger.GenerateUUID()
	return string.gsub(
		HttpService:GenerateGUID(false),
		"-",
		""
	)
end

-- // Actions

return table.freeze(EngineDebugger)