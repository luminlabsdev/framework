# Framework

The main class of LuminFramework.

## Properties

---

### `version`

The current version of the framework.

- `string`

## Functions

---

### `Start`

Starts the framework and prepares all of the cycles/controllers.

**Parameters**

- **directories:** `{ Instance }`<br>
A list of directories that have controllers inside of them. Only children are loaded.

- **filter:** `((module: ModuleScript) -> boolean)?`<br>
A filter that runs on every file in the specified directories. Return true to allow module.

- **callback:** `(() -> ())?`<br>
Runs when the start process has finished

**Returns**

- `void`

---

### `New`

Creates a new controller for management of various tasks. Returned table is frozen.

**Parameters**

- **members:** `{ any }`<br>
This is where functions, properties, and methods are stored. Use this like a generic module

- **order:** `number?`<br>
A specified load order. Defaults to 1 / no specific order

**Returns**

- [`Controller`](./controller.md)

---

### `Lifecycle`

Creates a new cycle that hooks onto already existing controller methods.

**Parameters**

- **type:** `LifecycleType`<br>
A designated lfiecycle type

**Returns**

- [`Lifecycle`](./lifecycle.md)
