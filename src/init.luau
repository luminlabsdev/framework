-- Variables

local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")

local Utility = script.Utility

local Storage = require(Utility.Storage)
local Debug = require(Utility.Debug)
local Types = require(script.Types)
local Signal = require(script.Parent.signal)
local Promise = require(script.Parent.promise)
local Spawn = require(script.Parent.spawn)

local StorageNodes = Storage.Nodes
local Started = false
local WorkerServices = {
	RunService = RunService,
	PlayerService = PlayerService,
}
local WorkerNames = {
	RunService = {
		"PostSimulation",
		"PreSimulation",
		"PreAnimation",
		"PreRender",
	},
	PlayerService = {
		"PlayerAdded",
		"PlayerRemoving",
	},
}

-- Functions

-- Creates a new signal, if it has no name it will remain anonymous
local function GetSignal(name: string?): Signal.Signal<any>
	if not name then
		return Signal.new()
	end

	if not StorageNodes.Signals[name] then
		StorageNodes.Signals[name] = Signal.new()
	end

	return StorageNodes.Signals[name]
end

-- Loads any expected controllers in the order of that they were expected
local function LoadExpectedControllers()
	for _, expectedController in Storage.ExpectedControllers do
		if not expectedController.Init then
			continue
		end
		Debug.Assert(type(expectedController.Init) == "function", "IncorrectType", "Init", "function")
		Debug.Assert(expectedController.Name, "ItemNotOptional", "Name")
		Debug.Assert(expectedController.IsController, "ItemNotOptional", "IsController")
		local _, err
		_, err = xpcall(function()
			debug.setmemorycategory(expectedController.Name)
			expectedController.Init()
		end, function()
			Debug.Error("CannotInit", debug.info(2, "ln"), err)
		end)
	end
end

-- Loads all the controllers internally
local function LoadControllers(modules: { Instance })
	-- Import all controllers so they are functional
	local Controllers = {}
	for _, container in modules do
		for _, module in container:GetChildren() do
			if not module:IsA("ModuleScript") then
				continue
			end
			table.insert(Controllers, (require)(module))
		end
	end

	-- Load expected controllers first
	LoadExpectedControllers()

	-- Load other controllers where load order does not matter
	for _, controller in Controllers do
		if not controller.Init then
			continue
		end
		Debug.Assert(type(controller.Init) == "function", "IncorrectType", "Init", "function")
		Debug.Assert(controller.Name, "ItemNotOptional", "Name")
		Debug.Assert(controller.IsController, "ItemNotOptional", "IsController")
		local _, err
		_, err = xpcall(function()
			debug.setmemorycategory(controller.Name)
			controller.Init()
		end, function()
			Debug.Error("CannotInit", debug.info(2, "ln"), err)
		end)
	end
	return Controllers
end

-- Starts all the controllers internally
local function StartControllers(controllers: { any })
	for _, controller in controllers do
		if not controller.Start then
			continue
		end
		Debug.Assert(type(controller.Start) == "function", "IncorrectType", "Start", "function")
		local _, err
		_, err = xpcall(function()
			debug.setmemorycategory(controller.Name)
			controller.Start()
		end, function()
			Debug.Error("CannotInit", debug.info(2, "ln"), err)
		end)
	end
end

-- Starts all the workers internally
local function StartWorkers()
	for service, connectionTypes in Storage.Workers do
		for connectionType, connectionList in connectionTypes do
			for _, worker in connectionList do
				Debug.Assert(worker.IsWorker, "ItemNotOptional", "IsWorker")
				Debug.Assert(WorkerServices[service][worker.Type], "ItemNotFound", worker.Type)
				WorkerServices[service][worker.Type]:Connect(function(...)
					Spawn(worker.Callback, ...)
				end)
			end
		end
	end
end

-- Finds an item within a table where the name prop is equal to the provided name
local function Find(name: string, table: {any}): number?
	for index, item in table do
		if item.Name and item.Name == name then
			return index
		end
	end
	return nil
end

-- Starts the framework
local function Start(modules: { Instance }?)
	if Started then
		return Promise.reject(Debug.Append("AlreadyStarted"))
	end

	return Promise.new(function(resolve)
		if modules then
			resolve(LoadControllers(modules))
		end
	end):andThen(function(controllers)
		-- Call start function and start workers; all modules and workers are now safe to use
		StartControllers(controllers)
		StartWorkers()
		-- Finish startup and make values certain/frozen
		Started = true
		table.freeze(Storage.Controllers)
		table.freeze(Storage.Workers)
	end)
end

-- Defines an expect controller method for dependency injection
local function Expect<T>(controller: T): Types.Controller<T>
	Debug.Assert(not Started, "AlreadyStarted")
	Debug.Assert((controller :: Types.Controller<T>).IsController, "ItemNotOptional", "IsController")
	table.remove(Storage.Controllers, Find((controller :: Types.Controller<T>).Name :: any, Storage.Controllers))
	table.insert(Storage.ExpectedControllers, controller :: Types.Controller<T>)
	return controller :: Types.Controller<T>
end

-- Creates a new controller for managing a variety of tasks, if it wasn't defined already
local function Controller<T>(name: string, members: Types.Controller<T>): T
	Debug.Assert(not Started, "AlreadyStarted")
	Debug.Assert(not Find(name, Storage.Controllers), "ControllerAlreadyExists", name)
	Debug.Assert(string.len(name) > 0, "NameTooShort")
	table.insert(Storage.Controllers, members)
	members.Name = name
	members.IsController = true
	return members
end

-- Creates a new worker which is used for management of ongoing tasks in the background
local function Worker(type: Types.WorkerType, callback: (...any) -> ())
	Debug.Assert(not Started, "AlreadyStarted")
	Debug.Assert(not table.find(WorkerNames, type), "ItemNotFound", type)
	if type == "PreRender" and not RunService:IsClient() then
		Debug.Error("IncorrectContext", "WorkerType")
	end
	local Worker = {}
	Worker.Type = type
	Worker.Callback = callback
	Worker.IsWorker = true
	for service, connectionTypes in Storage.Workers do
		for connectionType, connectionList in connectionTypes do
			if connectionType == type then
				table.insert(connectionList, Worker :: any)
			end
		end
	end
end

-- Module

return {
	Started = Started,
	Start = Start,
	Controller = Controller,
	Expect = Expect,
	Worker = Worker,
	Signal = GetSignal,
}
