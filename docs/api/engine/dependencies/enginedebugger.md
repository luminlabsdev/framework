# Debugger

Contains functions useful for debugging code which abide by user settings.

## Types

### CallStack <Badge type="tip" text="private" />

No description

---

### ExpectedType <Badge type="tip" text="public" />

This type contains every roblox user data and generic type.

## Properties

### CachedDebugCalls

A list of cached debug calls for the current environment.

* **[Array](/api/engine/types#array)\<[Array](/api/engine/types#array)<string\>**

---

### CachedLogs

A list of cached logs/events for the current environment.

* **any**

## Functions

### Debug

The main debug handler, adds a prefix to logs sent out and respects logging settings.

**Parameters**

* **debugHandler:** `(prefix: string, T...) -> ()`\
The function to run on debug, for example `Debugger.Debug(print, "Hello, world!")`

* **arguments:** `T...`\
The contents to be passed to the function

**Returns**

* **void**

---

### DebugPrefix

Sames as [`Debug`](#debug), but allows a custom prefix.

**Parameters**

* **debugHandler:** `(prefix: string, T...) -> ()`\
The function to run on debug, for example `Debugger.Debug(print, "Hello, world!")`

* **prefix:** `string`\
The prefix to be put in front of the message

* **arguments:** `T...`\
The contents to be passed to the function

**Returns**

* **void**

---

### ClearOutput

Clears the output and cached stack traces, with the option of also clearing cached debug calls.

**Parameters**

* **clearDebugCallCache:** `boolean?`\
Decides whether or not the debug call cache should be cleared too

**Returns**

* **void**

---

### Assert

Checks if a value is nil / false and runs the provided handler. This always respects the debugger.

**Parameters**

* **assertionHandler:** `(...any) -> ()`\
The handler to run if the assertion is not truthy

* **assertion:** `T`\
The value to assert, this is checked

* **message:** `string`\
The message to pass to the handler

* **arguments:** `Tuple`\
Any values to format from `message`, functions identically to `string.format`

**Returns**

* **T**

---

### GetCallStack

Gets the call stack of any script within CanaryEngine.

**Parameters**

* **instance:** `LuaSourceContainer`\
The script to start the hierarchy at

* **stackName:** `string?`\
The name of the stack, defaults to the stack number

**Returns**

* **[CallStack](#callstack)**

---

### LogEvent

Logs an event in a script, which is then stored in a cache for that script. This allows you to make sure code is running while not cluttering the output in the live game.

**Parameters**

* **instance:** `LuaSourceContainer`\
The instance to cache the debug logs at

* **eventName:** `string`\
The name to print and log it as

* **silent:** `boolean?`\
Decides whether or not to print the log, defaults to `false`.

**Returns**

* **void**

---

### GenerateUUID

Generates a UUID with safe characters.

**Returns**

* **string**