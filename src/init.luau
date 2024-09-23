-- Variables

local Packages = script.Parent

local Types = require(script.Types)
local Logs = require(script.Logs)

local Debugger = require(Packages.debugger)

local Started = false

local Controllers: { Types.Controller<any> } = {}
local Cycles: { Types.Cycle<...any> } = {}

-- Functions

-- Starts/inits a controller internally
local function LoadController(callback: () -> (), controllerType: "Start" | "Init")
	-- Runs `Start` or `Init` and implements verbose debugging
	Debugger.Assert(type(callback) == "function", "IncorrectType", controllerType, "function")
	local Success, Err: Debugger.ParsedError = xpcall(callback :: any, Debugger.Parse)
	if not Success then
		Debugger.Fatal(`Cannot{controllerType}`, Err.Message)
	end
end

-- Starts/inits a list of controllers internally, and starts cycles within those
local function LoadControllersAsync(controllers: { Types.Controller<any> })
	local UsedControllers = {}

	for _, controller in controllers do
        for _, cycle in Cycles do
            if (controller :: any)[cycle.Name] then
                table.insert(cycle.Listeners, (controller :: any)[cycle.Name])
            end
        end

		-- Check if the controller uses any dependencies
		if controller.Uses and type(controller.Uses) == "table" then
			table.freeze(controller.Uses)
			for _, usedController in controller.Uses do
				if usedController["Init"] then
					LoadController(usedController.Init, "Init")
					table.insert(UsedControllers, usedController)
				end
			end
		end

		if controller.Init and not table.find(UsedControllers, controller) then
			LoadController(controller.Init, "Init")
		end

		if controller.Start then
			LoadController(controller.Start, "Start")
		end
	end
end

-- Loads all of the provided directories
local function Import(directories: { Instance }, filter: ((ModuleScript) -> boolean)?): { Types.Controller<any> }
	local Controllers = {}
	for _, driectory in directories do
		for _, module in driectory:GetChildren() do
			if not (module:IsA("ModuleScript") or filter and filter(module :: ModuleScript)) then
				continue
			end
			table.insert(Controllers, (require)(module))
		end
	end
	return Controllers
end

--[=[
	Starts the framework, loading all the created controllers and starting cycles.

	[Learn More](https://luminlabsdev.github.io/framework/api/#start)
]=]
local function Start(directories: { Instance }, filter: ((ModuleScript) -> boolean)?, callback: (() -> ())?)
	Debugger.Assert(not Started, "AlreadyStarted")
	LoadControllersAsync(Import(directories, filter))
	Started = true

	if callback then
		callback()
	end

	table.freeze(Controllers)
	table.freeze(Cycles)
end

--[=[
	Creates a new controller for management of various tasks. Returned table is frozen.

	[Learn More](https://luminlabsdev.github.io/framework/api/#new)
]=]
local function New<T>(members: Types.Controller<T>, order: number?): T
	Debugger.Assert(not Started, "AlreadyStarted")
	Debugger.Assert(members, "MustProvide", "members")
	table.freeze(members)
	table.insert(Controllers, order or 1, members)
	return members
end

--[=[
	Fires the callback for all of the listeners to the cycle.

	[Learn More](https://luminlabsdev.github.io/framework/api/cycle/#fire)
]=]
local function Fire<T...>(self: Types.Cycle<T...>, ...: T...)
	for _, listener in self.Listeners do
		task.spawn(listener, ...)
	end
end

--[=[
	Creates a new cycle that hooks onto already existing controller methods.

	[Learn More](https://luminlabsdev.github.io/framework/api/#cycle)
]=]
local function Cycle(name: string): Types.Cycle<...any>
	Debugger.Assert(not Started, "AlreadyStarted")
	Debugger.Assert(name, "MustProvide", "name")
    local Cycle = table.freeze({
        Name = name,
		Listeners = {},
		Fire = Fire,
    })
    table.insert(Cycles, Cycle)
	return Cycle
end

-- Debugger

Debugger.SetLogs(Logs)
Debugger.SetMetadata({
	PackageName = "Framework",
	PackageURL = "https://github.com/luminlabsdev/framework",
	TraceLevel = 3,
})

-- Types

export type Cycle<T...> = Types.Cycle<T...>
export type Controller<T> = Types.Controller<T>

-- Module

return table.freeze({
	-- Version
	version = { major = 9, minor = 0, patch = 0, rc = 9 },

	-- Starter
	Start = Start,

	-- Constructors
	New = New,
	Cycle = Cycle,
})
