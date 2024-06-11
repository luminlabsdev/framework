# Network

The library to create network events and functions.

## Functions

### `Event`

The contstructor for creating new network events.

**Parameters**

* **name:** `string`\
The name of the new object

* **reliable:** `boolean?`\
Whether or not the object created is reliable. Defaults to true

**Returns**

* [**Promise**](https://eryn.io/roblox-lua-promise/)<[**EventClient | EventServer**](/api/network/server/event)>

---

### `Function`

The contstructor for creating new network functions.

**Parameters**

* **name:** `string`\
The name of the new object

* **reliable:** `boolean?`\
Whether or not the object created is reliable. Defaults to true

**Returns**

* [**Promise**](https://eryn.io/roblox-lua-promise/)<[**FunctionClient | FunctionServer**](/api/network/client/event)>