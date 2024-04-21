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

### GetCallStack

Gets the call stack of any script within LuminFramework.

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

* **formatters** `...any`\
Pass any formats here, `eventName` will act just like `string.format`

**Returns**

* **void**

---

### GenerateUUID

Generates a UUID with safe characters.

**Returns**

* **string**