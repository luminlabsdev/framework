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

local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")

local Runtime = require(EngineVendor.Runtime)
local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

local Prefix = "[Debugger]:"
local ValidCallstackNames = {
	"EngineClient",
	"EngineServer",
	"EngineReplicated",
	"EngineReplicatedFirst",
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

EngineDebugger.CachedDebugCalls = { }
EngineDebugger.CachedLogs = { }
EngineDebugger.InternalCachedLogs = { }

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

function EngineDebugger.Debug(debugHandler: (...any) -> (), arguments: {any} | any, prefix: string?, respectDebugger: boolean?)
	prefix = prefix or Prefix

	if respectDebugger == nil then
		respectDebugger = true
	end

	table.insert(EngineDebugger.CachedDebugCalls, arguments)

	if not respectDebugger or(RuntimeContext.Studio and RuntimeSettings.StudioDebugEnabled) or RuntimeSettings.LiveGameDebugEnabled then
		if type(arguments) == "table" then
			debugHandler(prefix, table.unpack(arguments))
		else
			debugHandler(`{prefix} {arguments}`)
		end
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
	if not instance:IsA("LuaSourceContainer") then
		EngineDebugger.DebugInvalidData(1, "GetCallStack", "LuaSourceContainer", instance)
	end

	stackName = stackName or `NewStack`
	
	local Source = GetAncestorsUntilParentFolder(instance)
	local DefinedLine = debug.traceback():split(":")
	
	local StackTable = { }
	
	StackTable.Name = stackName
	StackTable.Source = Source[1]
	StackTable.SourceTree = Source[2]
	StackTable.DefinedLine = tonumber(DefinedLine[#DefinedLine]:gsub("\n", ""), nil)
	
	return StackTable
end

function EngineDebugger.DebugInvalidData(paramNumber: number, funcName: string, expectedType: ExpectedType, param: unknown, debugHander: (...any) -> ())
	warn("DebugInvalidData is deprecated as of 4.0.0, please Guard instead")
	local ParamType = typeof(param)

	if ParamType ~= expectedType then
		local ErrorString = `invalid argument #{paramNumber} to '{funcName}' ({expectedType} expected, got {ParamType})`
		if debugHander then
			debugHander(ErrorString)
			return
		end
		error(ErrorString)
	end
end

function EngineDebugger.LogEvent(instance: LuaSourceContainer, eventName: string, printLog: boolean?, isInternal: boolean?)
	if printLog == nil then
		printLog = true
	end
	
	if not EngineDebugger.CachedLogs[instance] then
		EngineDebugger.CachedLogs[instance] = { }
	end

	if isInternal then
		table.insert(EngineDebugger.CachedInternalLogs[instance], eventName)
	else
		table.insert(EngineDebugger.CachedLogs[instance], eventName)
	end

	if printLog then
		EngineDebugger.Debug(print, eventName, "[Event]:")
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