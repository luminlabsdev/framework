# Debugger

Contains functions useful for debugging code which abide by user settings.

## Types

### CallStack <Badge type="tip" text="private" />

A generic sum of callstack data.

## Properties

### SessionLogs

A list of cached logs/events for the current environment.

* **{ string }**

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

### GetCallStack

Gets the call stack of any script within CanaryEngine.

**Parameters**

* **instance:** `LuaSourceContainer`\
The script to start the hierarchy at

**Returns**

* **[CallStack](#callstack)**

---

### LogEvent

Logs an event in a script, which is then stored in a global cache. This allows you to make sure code is running while not cluttering the output in the live game. Keep in mind that this is automatically prints; to disable this turn off `Framework.ShowLoggedEvents` (attribute).

**Parameters**

* **eventName:** `string`\
The name to print and log it as

**Returns**

* **void**

---

### GenerateUUID

Generates a UUID with safe characters.

**Returns**

* **string**