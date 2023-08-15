-- // Package

--[=[
	The parent of all classes.

	@class Debugger
]=]
local Debugger = { }

--[=[
	The callstack type.

	@private

	@type CallStack {Name: string, Source: string, DefinedLine: number}
	@within Debugger
]=]
type CallStack = {Name: string, Source: string, DefinedLine: number}

--[=[
	This type contains every roblox user data and generic type.

	@type ExpectedType "Axes" | "BrickColor" | "CatalogSearchParams" | "CFrame" | "Color3" | "ColorSequence" | "ColorSequenceKeypoint" | "Content" | "DateTime" | "DockWidgetPluginGuiInfo" | "Enum" | "EnumItem" | "Enums" | "Faces" | "FloatCurveKey" | "Font" | "Instance" | "NumberRange" | "NumberSequence" | "NumberSequenceKeyPoint" | "OverlapParams" | "PathWaypoint" | "PhysicalProperties" | "Random" | "Ray" | "RayastParams" | "RaycastResult" | "RBXScriptConnection" | "RBXScriptSignal" | "Rect" | "Region3" | "Region3int16" | "SharedTable" | "TweenInfo" | "UDim" | "UDim2" | "Vector2" | "Vector2int16" | "Vector3" | "Vector3int16" | "nil" | "boolean" | "number" | "string" | "function" | "userdata" | "thread" | "table"
	@within Debugger
]=]
export type ExpectedType = "Axes" | "BrickColor" | "CatalogSearchParams" | "CFrame" | "Color3" | "ColorSequence" | "ColorSequenceKeypoint" | "Content" | "DateTime"
| "DockWidgetPluginGuiInfo" | "Enum" | "EnumItem" | "Enums" | "Faces" | "FloatCurveKey" | "Font" | "Instance" | "NumberRange" | "NumberSequence"
| "NumberSequenceKeyPoint" | "OverlapParams" | "PathWaypoint" | "PhysicalProperties" | "Random" | "Ray" | "RayastParams" | "RaycastResult" | "RBXScriptConnection"
| "RBXScriptSignal" | "Rect" | "Region3" | "Region3int16" | "SharedTable" | "TweenInfo" | "UDim" | "UDim2" | "Vector2" | "Vector2int16" | "Vector3" | "Vector3int16"
| "nil" | "boolean" | "number" | "string" | "function" | "userdata" | "thread" | "table"

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

	for _, ancestor in Ancestors do
		if CompleteString == "" then
			CompleteString = ancestor.Name
			continue
		end

		CompleteString = `{ancestor.Name}.{CompleteString}`
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
function Debugger.Debug(debugHandler: (...any) -> (), arguments: {any} | any, prefix: string?, respectDebugger: boolean?)
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
function Debugger.GetCallStack(instance: Script | ModuleScript, stackName: string?): {Name: string, Source: string, DefinedLine: number}
	if not (instance:IsA("ModuleScript") or instance:IsA("Script")) then
		Debugger.DebugInvalidData(1, "GetCallStack", "LuaSourceContainer", instance)
		return
	end

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

--[=[
	Errors if the param does not have the same type as what is expected.

	@param paramNumber number -- The number of which param errored, 1 would be the first param
	@param funcName string -- The name of the function
	@param expectedType ExpectedType -- The type that was expected of `param`
	@param param T -- The param which caused the error
]=]
function Debugger.DebugInvalidData(paramNumber: number, funcName: string, expectedType: ExpectedType, param: unknown, debugHander: (...any) -> ())
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

-- // Actions

return Debugger