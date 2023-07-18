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
	["error"] = error;
}

-- // Functions

local function IsStudioAndDebugEnabled(debugType: "print" | "warn" | "error", ...: any)
	if (RuntimeContext.Studio and RuntimeSettings.StudioDebugEnabled) or (RuntimeSettings.LiveGameDebugger) then
		if debugType ~= "error" then
			ValidDebugFunctionList[debugType](Prefix, ...)
			return
		end
		
		ValidDebugFunctionList.error(string.format("%s %s", Prefix, ...), 0)
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

function Package.error<T>(msg: T)
	IsStudioAndDebugEnabled("error", msg)
end

-- // Actions

return Package