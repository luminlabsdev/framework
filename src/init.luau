-- Variables

local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")

local Packages = script.Parent

local Storage = require(script.Storage)
local Types = require(script.Types)
local LogList = require(script.LogList)

local Debugger = require(Packages.debugger)
local Spawn = require(Packages.spawn)

local Started = false

local DefaultCycleTypes = {
	PostSimulation = RunService.PostSimulation,
	PreSimulation = RunService.PreSimulation,
	PreAnimation = RunService.PreAnimation,
	PreRender = RunService.PreRender,
	PlayerAdded = PlayerService.PlayerAdded,
	PlayerRemoving = PlayerService.PlayerRemoving,
}

-- Functions

-- Starts/inits a controller internally
local function LoadController(callback: () -> (), type: "Start" | "Init")
	local Success, Err: Debugger.ParsedError = xpcall(callback :: any, Debugger.Parse)
	if not Success then
		Debugger.Fatal(`Cannot{type}`, Err.Message)
	end
end

-- Starts/inits a list of controllers internally
local function LoadAllControllers(controllers: { Types.Controller<any> })
	local InitiatedControllers = {}

	for _, controller in controllers do
		if controller["Uses"] and type(controller.Uses) == "table" then
			table.freeze(controller.Uses)
			for _, usedController in controller.Uses :: any do
                if usedController["Init"] then
				    Debugger.Assert(type(usedController["Init"]) == "function", "IncorrectType", "Init", "function")
					LoadController(usedController.Init, "Init")
					table.insert(InitiatedControllers, usedController)
					table.remove(controllers, table.find(controllers, controller))
				end
			end
		end

		if controller["Init"] then
			Debugger.Assert(type(controller["Init"]) == "function", "IncorrectType", "Init", "function")
			LoadController(controller.Init, "Init")
			table.insert(InitiatedControllers, controller)
		end
	end

	for _, controller in InitiatedControllers do
		if controller["Start"] then
			Debugger.Assert(type(controller["Start"]) == "function", "IncorrectType", "Start", "function")
			LoadController(controller.Start, "Start")
		end
	end
end

-- Starts all the workers internally
local function StartCycles()
	for _, cycle in Storage.Cycles do
		cycle.Connection:Connect(function(...)
			Spawn(cycle.Callback, ...)
		end)
	end
end

--[=[
	Loads all of the provided modules, going through a `filter` if available.

	[Learn More](https://luminlabsdev.github.io/framework/api/#load)
]=]
local function Load(containers: { Instance }, filter: ((ModuleScript) -> boolean)?): { Types.Controller<any> }
	local Controllers = {}
	for _, container in containers do
		for _, module in container:GetChildren() do
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
local function Start(loaded: { Types.Controller<any> }, callback: (() -> ())?)
	Debugger.Assert(not Started, "AlreadyStarted")

	LoadAllControllers(loaded) -- Yields until they are loaded
	StartCycles()

	Started = true

	if callback then
		callback()
	end

	table.freeze(Storage.Controllers)
	table.freeze(Storage.Cycles)
end

--[=[
	Creates a new controller for management of various tasks.

	[Learn More](https://luminlabsdev.github.io/framework/api/#new)
]=]
local function New<T>(members: Types.Controller<T>): T
	Debugger.Assert(not Started, "AlreadyStarted")
	table.insert(Storage.Controllers, members)
	return members
end

--[=[
	Creates a new cycle for management of various tasks that happen continously in the background.

	[Learn More](https://luminlabsdev.github.io/framework/api/#cycle)
]=]
local function Cycle(type: Types.CycleType, callback: (...any) -> ())
	Debugger.Assert(not Started, "AlreadyStarted")
	Debugger.Assert(DefaultCycleTypes[type], "ItemNotFound", type)
	if type == "PreRender" and not RunService:IsClient() then
		Debugger.Fatal("IncorrectContext", "WorkerType")
	end
	table.insert(
		Storage.Cycles,
		table.freeze({
			Connection = DefaultCycleTypes[type],
			Callback = callback,
		})
	)
end

-- Debugger

Debugger.SetLogs(LogList)
Debugger.SetMetadata({
	PackageName = "Framework",
	PackageURL = "https://github.com/luminlabsdev/framework",
	TraceLevel = 3,
})

-- Module

return table.freeze({
	-- Version
	version = { major = 9, minor = 0, patch = 0, rc = 9 },

	-- Loaders
	Start = Start,
	Load = Load,

	-- Constructors
	New = New,
	Cycle = Cycle,
})
