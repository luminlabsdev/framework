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
local StartedCallback = nil

local DefaultWorkerTypes = {
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
	local Success, Err = xpcall(callback :: any, Debugger.Parse)
	if not Success then
		local Message = Err :: Debugger.ParsedError
		Debugger.Fatal(`Cannot{type}`, Message.Message)
	end
end

-- Starts/inits a list of controllers internally
local function LoadAllControllers(controllers: { Types.DevController<any> })
	for _, controller in controllers do
		if controller["Uses"] and type(controller.Uses) == "table" then
			for _, usedController in controller.Uses :: any do
                if usedController["Init"] then
                    LoadController(usedController.Init, "Init")
                    table.remove(controllers, table.find(controllers, controller))
                end
			end
		end
		if controller["Init"] and type(controller.Init) == "function" then
			LoadController(controller.Init, "Init")
		end
		if controller["Start"] and type(controller.Start) == "function" then
			LoadController(controller.Start, "Start")
		end
	end
end

-- Starts all the workers internally
local function StartWorkers()
	for _, worker in Storage.Workers do
		worker.Connection:Connect(function(...)
			Spawn(worker.Callback, ...)
		end)
	end
end

--[=[
	Loads all of the provided modules, going through a `filter` if available

	[Learn More](https://lumin-dev.github.io/LuminFramework/api/#load)
]=]
local function Load(containers: { Instance }, filter: ((ModuleScript) -> boolean)?): { Types.DevController<any> }
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
	Starts the framework, loading all the created controllers and starting Workers.

	[Learn More](https://lumin-dev.github.io/LuminFramework/api/#start)
]=]
local function Start(loaded: { Types.DevController<any> })
	Debugger.Assert(Started, "AlreadyStarted")

	LoadAllControllers(loaded)
	StartWorkers()

	Started = true

	if StartedCallback then
		StartedCallback()
	end

	table.freeze(Storage.Controllers)
	table.freeze(Storage.Workers)
end

--[=[
	Creates a new controller for management of various tasks.

	[Learn More](https://lumin-dev.github.io/LuminFramework/api/#new)
]=]
local function New<T>(members: Types.DevController<T>): T
	Debugger.Assert(Started, "AlreadyStarted")
	table.insert(Storage.Controllers, members)
	return members
end

--[=[
	Creates a new worker for management of various tasks that happen continously in the background.

	[Learn More](https://lumin-dev.github.io/LuminFramework/api/#worker)
]=]
local function Worker(type: Types.WorkerType, callback: (...any) -> ())
	Debugger.Assert(Started, "AlreadyStarted")
	Debugger.Assert(not DefaultWorkerTypes[type], "ItemNotFound", type)
    if type == "PreRender" and not RunService:IsClient() then
        Debugger.Fatal("IncorrectContext", "WorkerType")
    end
	table.insert(
		Storage.Workers,
		table.freeze({
			Connection = DefaultWorkerTypes[type],
			Callback = callback,
		})
	)
end

--[=[
	Runs the provided callback function when the framework is completely started

	[Learn More](https://lumin-dev.github.io/LuminFramework/api/#onstart)
]=]
local function OnStart(callback: () -> ())
	Debugger.Assert(Started, "AlreadyStarted")
	StartedCallback = callback
end

-- Debugger

Debugger.SetLogs(LogList)
Debugger.SetMetadata({
	PackageName = "Lumin Framework",
	PackageURL = "https://github.com/lumin-dev/LuminFramework",
	TraceLevel = 3,
})

-- Module

return table.freeze({
	-- Version
	version = { major = 9, minor = 0, patch = 0, rc = 7 },

	-- Loaders
	Start = Start,
	Load = Load,

	-- Constructors
	New = New,
	Worker = Worker,

	-- Callbacks
	OnStart = OnStart,
})
