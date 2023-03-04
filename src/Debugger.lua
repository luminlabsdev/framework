-- // Package

local Package = { }

-- // Variables

local Runtime = require(script.Parent.Runtime)

local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

local Prefix = "[Debugger]:"

local ValidDebugFunctionList = {
	["warn"] = warn;
	["print"] = print;
}

-- // Functions

local function IsStudioAndDebugEnabled(debugType: "print" | "warn", ...: any)
	if RuntimeContext.Studio and RuntimeSettings.StudioDebugEnabled then
		ValidDebugFunctionList[debugType](Prefix, ...)
	end
end

function Package.print(...: any)
	IsStudioAndDebugEnabled("print", ...)
end

function Package.warn(...: any)
	IsStudioAndDebugEnabled("warn", ...)
end

function Package.silenterror<T>(msg: T)
	local thread = task.spawn(error, msg, 0)
	task.cancel(thread)
	thread = nil
end

-- // Actions

return Package
