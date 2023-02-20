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
		ValidDebugFunctionList[debugType](...)
	end
end

function Package.print<T...>(...: T...)
	IsStudioAndDebugEnabled("print", ...)
end

function Package.warn<T...>(...: T...)
	IsStudioAndDebugEnabled("warn", ...)
end

function Package.assert<a, b>(assertion: a, msg: b): a?
	if not (assertion) then
		error(msg)
		return nil
	end
	return assertion
end

function Package.assertmulti<a, b>(...: {a | b})
	for index, value in ipairs({...}) do
		if not (value[1]) then
			error(value[2])
		end
	end
end

-- // Actions

return Package
