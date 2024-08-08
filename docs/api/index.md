# Framework

The main class of LuminFramework.

## Properties

### `Started`

Whether or not the framework has started yet

- **boolean**

## Functions

### `Start`

Starts the framework and prepares all of the workers/controllers.

**Parameters**

- **modules:** `Instance?`\
A folder of modules to load, this will import every descendant

**Returns**

- [**Promise**](https://eryn.io/roblox-lua-promise/)

---

### `Controller`

Creates a new controller, this is essentially a service-like infastructure for the framework. This is preferred to use over vanilla tables, especially in conjunction with `Start`

**Parameters**

* **name:** `string`\
The name of the controller; cannot already exist and must be longer than 0 characters

* **members:** `{ any }`\
This is where functions, properties, and methods are stored. Use this like a generic module

**Returns**

* [**Controller**](./controller.md)

---

### `Worker`

Implements lifecycle methods into the framework, as its own object called a Worker

**Parameters**

* **type:** `WorkerType`\
A designated worker type

* **callback:** `(deltaTime: number) -> ()`\
The callback to run for the worker type

**Returns**

* [**Worker**](./worker.md)

---

### `Signal`

Creates/references a signal of the given name, create a new anonymous signal by leaving the name blank.

**Parameters**

* **name:** `string?`\
The name of the signal

**Returns**

* [**Signal**](https://sleitnick.github.io/RbxUtil/api/Signal/)