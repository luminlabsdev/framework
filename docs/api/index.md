# Framework

The main class of LuminFramework.

## Properties

---

### `version`

The current version of the framework.

- **string**

## Functions

---

### `Start`

Starts the framework and prepares all of the cycles/controllers.

**Parameters**

- **loaded:** `{ Controller }`<br>
A list of already loaded controllers, should be from `.Load`

- **callback:** `(() -> ())?`<br>
Runs when the start process has finished

**Returns**

- **void**

---

### `New`

Creates a new controller for management of various tasks.

**Parameters**

- **members:** `{ any }`<br>
This is where functions, properties, and methods are stored. Use this like a generic module

**Returns**

- [**Controller**](./controller.md)

---

### `Cycle`

Creates a new cycle for management of various tasks that happen continously in the background.

**Parameters**

- **type:** `CycleType`<br>
A designated cycle type

- **callback:** `(args: ...any) -> ()`<br>
The callback to run for the cycle type

**Returns**

- **void**

---

### `Load`

Loads all of the provided modules, going through a `filter` if available.

**Parameters**

- **containers:** `{ Instance }`<br>
A list of containers of which the children will be loaded of

- **filter:** `((ModuleScript) -> boolean)?`<br>
A function that runs for every module script, returning true will allow the module to load

**Returns**

- **void**
