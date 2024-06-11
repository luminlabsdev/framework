# LuminFramework

The main class of LuminFramework.

## Properties

### `Promise` <Badge type="tip" text="read only" />

A reference to evaera's Promise module.

* [**Promise**](https://eryn.io/roblox-lua-promise/)

## Functions

### `Server` <Badge type="danger" text="server" />

Gets the server-sided interface of LuminFramework.

**Returns**

* [**Server**](/api/server)

---

### `Client` <Badge type="danger" text="client" /> <Badge type="warning" text="yields" />

Gets the client-sided interface of LuminFramework.

**Returns**

* [**Client**](/api/client)

---

### `Load`

Imports any modules of the parent provided. Non-modules will be filtered out automatically.

**Parameters**

* **parent:** `Instance`\
The parent of which the modules are located

* **filter:** `(module: ModuleScript) -> boolean?`\
Allows you to filter through a module, return `false` for it to not be imported

**Returns**

* **void**

---

### `Signal`

Creates/references a signal of the given name, create a new anonymous signal by leaving the name blank.

**Parameters**

* **name:** `string?`\
The name of the signal

**Returns**

* [**Signal**](https://sleitnick.github.io/RbxUtil/api/Signal/)