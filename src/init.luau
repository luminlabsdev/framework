-- Variables

local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")

local Packages = script.Parent

local Types = require(script.Types)
local Logs = require(script.Logs)

local Debugger = require(Packages.debugger)

local Started = false

local Controllers: { Types.Controller<any> } = {}
local Lifecycles: { Types.Lifecycle<...any> } = {}
local DefaultLifecycles: { [string]: RBXScriptSignal } = {
	PostSimulation = RunService.PostSimulation,
	PreSimulation = RunService.PreSimulation,
	PreRender = RunService.PreRender,
	PreAnimation = RunService.PreAnimation,
	PlayerAdded = PlayerService.PlayerAdded,
	PlayerRemoving = PlayerService.PlayerRemoving,
}

-- Functions

-- The default callback for lifecycle fires
local function DefaultLifecycleCallback(self: Types.Lifecycle<...any>, ...: any)
	for _, listener in self.Listeners do
		task.spawn(listener, ...)
	end
end

-- Starts/inits a controller internally
local function LoadController(callback: () -> (), controllerType: "Start" | "Init")
	-- Runs `Start` or `Init` and implements verbose debugging
	Debugger.Assert(type(callback) == "function", "IncorrectType", controllerType, "function")
	local Success, Err: Debugger.ParsedError = xpcall(callback :: any, Debugger.Parse)
	if not Success then
		Debugger.Fatal(`Cannot{controllerType}`, Err.Message)
	end
end

--[=[
	Creates a new lifecycle that hooks onto already existing controller methods.

	[Learn More](https://luminlabsdev.github.io/framework/api/#lifecycle)
]=]
local function Lifecycle(
	name: Types.LifecycleType | string,
	callback: ((self: Types.Lifecycle<...any>, ...any) -> ())?
): Types.Lifecycle<...any>
	Debugger.Assert(not Started, "AlreadyStarted")
	Debugger.Assert(name, "MustProvide", "name")
	local Lifecycle = table.freeze({
		Name = name :: string,
		Listeners = {},
		Fire = callback or DefaultLifecycleCallback,
	})
	table.insert(Lifecycles, Lifecycle)
	return Lifecycle
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

-- Loads a default lifecycle
local function LoadDefaultLifecycle(lifecycle: Types.Lifecycle<...any>)
	local Event = DefaultLifecycles[lifecycle.Name]
	if RunService:IsServer() and (lifecycle.Name == "PreAnimation" or lifecycle.Name == "PreRender") then
		Debugger.Fatal("IncorrectContext", "PreAnimation or PreRender")
	end
	Event:Connect(function(...)
		lifecycle:Fire(...)
	end)
end

-- Starts/inits a list of controllers internally, and starts cycles within those
local function LoadControllersAsync(controllers: { Types.Controller<any> })
	local UsedControllers = {}

	for _, controller in controllers do
		-- Register lifecycles
		for _, lifecycle in Lifecycles do
			if (controller :: any)[lifecycle.Name] then
				table.insert(lifecycle.Listeners, (controller :: any)[lifecycle.Name])
				if DefaultLifecycles[lifecycle.Name] then
					LoadDefaultLifecycle(lifecycle)
				end
			end
		end

		-- Check if the controller uses any dependencies
		if controller.Uses and type(controller.Uses) == "table" then
			table.freeze(controller.Uses)
			-- Call init on used dependencies
			for _, usedController in controller.Uses do
				if usedController["Init"] then
					LoadController(usedController.Init, "Init")
					table.insert(UsedControllers, usedController)
				end
			end
		end

		-- Call init on non-used dependencies
		if controller.Init and not table.find(UsedControllers, controller) then
			LoadController(controller.Init, "Init")
		end

		-- Call start on all dependencies
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
	table.freeze(Lifecycles)
end

-- Debugger

Debugger.SetLogs(Logs)
Debugger.SetMetadata({
	PackageName = "Framework",
	PackageURL = "https://github.com/luminlabsdev/framework",
	TraceLevel = 3,
})

-- Types

export type Lifecycle<T...> = Types.Lifecycle<T...>
export type Controller<T> = Types.Controller<T>

-- Module

return table.freeze({
	-- Version
	version = { major = 9, minor = 0, patch = 0, rc = 9 },

	-- Starter
	Start = Start,

	-- Constructors
	New = New,
	Lifecycle = Lifecycle,
})
