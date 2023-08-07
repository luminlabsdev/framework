-- // Package

--[=[
	The parent of all classes.

	@class Debugger
]=]
local Debugger = { }

-- // Variables

local Runtime = require(script.Parent.Runtime)
local Utility = require()

local RuntimeContext = Runtime.Context
local RuntimeSettings = Runtime.Settings

local Prefix = "[Debugger]: "

-- // Functions

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

-- // Actions

return Debugger