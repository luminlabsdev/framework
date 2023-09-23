# EngineDebugger

Contains functions useful for debugging code which abide by user settings.

## Types

### CallStack <Badge type="tip" text="private" />

No description

---

### ExpectedType <Badge type="tip" text="public" />

This type contains every roblox user data and generic type.

## Properties

### CachedStackTraces

A list of cached stack traces for the current environment.

* [**Dictionary\<CallStack\>**](/api/engine/types#dictionary)

---

### CachedDebugCalls

A list of cached debug calls for the current environment.

* [**Array\<string | {string}\>**](/api/engine/types#array)

## Functions

### Debug

The main debug handler, adds a prefix to logs sent out and respects logging settings.

#### Parameters

* **debugHandler:** `(...T) -> ()`\
The function to run on debug, for example `Debugger.Debug(print, "Hello, world!")`

* **arguments:** `{string} | string`\
The contents to be passed to the function

* **prefix:** `string?`\
The prefix to put in front of the debug

* **respectDebugger:** `boolean?`\
Whether or not to respect the debugger, should always be true for correct use

#### Returns

* **void**

---

### ClearOutput

Clears the output and cached stack traces, with the option of also clearing cached debug calls.

#### Parameters

* **clearDebugCallCache:** `boolean?`\
Decides whether or not the debug call cache should be cleared too

#### Returns

* **void**

---

### Assert

Checks if a value is nil / false and runs the provided handler. This always respects the debugger.

#### Parameters

* **assertionHandler:** `(...any) -> ()`\
The handler to run if the assertion is not truthy

* **assertion:** `T`\
The value to assert, this is checked

* **message:** `string`\
The message to pass to the handler

* **arguments:** `Tuple`\
Any values to format from `message`, functions identically to `string.format`

#### Returns

* **T**

---

### GetCallStack

Gets the call stack of any script within CanaryEngine.

#### Parameters

* **instance:** `LuaSourceContainer`\
The script to start the hierarchy at

* **stackName:** `string?`\
The name of the stack, defaults to the stack number

#### Returns

* **[CallStack](#callstack)**

---

### DebugInvalidData <Badge type="warning" text="deprecated" />

Errors if the param does not have the same type as what is expected.

#### Parameters

* **paramNumber:** `number`\
The number of which param errored, 1 would be the first param

* **funcName:** `string`\
The name of the function

* **expectedType:** `ExpectedType`\
The type that was expected of `param`

* **param:** `T`\
The param which caused the error

* **debugHandler:** `(...any) -> ()`\
No description

#### Returns

* **void**

---

### LogEvent

Logs an event in a script, which is then stored in a cache for that script. This allows you to make sure code is running while not cluttering the output in the live game.

#### Parameters

* **instance:** `LuaSourceContainer`\
The instance to cache the debug logs at

* **eventName:** `string`\
The name to print and log it as

* **printLog:** `boolean?`\
Whether or not to pring the log using [EngineDebugger.Debug](#debug), defaults to true

#### Returns

* **void**

---

### GenerateUUID

Generates a UUID with safe characters.

#### Returns

* **string**