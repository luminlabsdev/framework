# CanaryEngine

The main class of CanaryEngine.

## Types

### Character <Badge type="tip" text="public" />

A simple R6 character type used when using [`CanaryEngineClient:GetPlayerCharacter`](/api/client#GetPlayerCharacter)

## Properties

### Runtime <Badge type="tip" text="read only" />

The runtime property contains settings that are set during runtime, and the current context of the server/client.

* [**Runtime**](/api/runtime/)

---

### Debugger <Badge type="tip" text="read only" />

The internal engine debugger, has useful functions to abide by debug settings.

* [**Debugger**](/api/debugger)

---

### Future <Badge type="tip" text="read only" />

A reference to the Future package, which is a optimized version of a Promise.

* [**Future**](https://util.redblox.dev/future.html)

---

### LoadTime <Badge type="tip" text="read only" />

The number in seconds of which the framework took to completely finish loading; is rounded by the nearest hundreth.

* **number**

## Functions

### GetFrameworkServer <Badge type="danger" text="server" />

Gets the server-sided interface of CanaryEngine.

**Returns**

* [**FrameworkServer**](/api/server)

---

### GetFrameworkClient <Badge type="danger" text="client" />

Gets the client-sided interface of CanaryEngine.

**Returns**

* [**FrameworkClient**](/api/client)

---

### GetFrameworkShared

Gets the shared interface of CanaryEngine. Currently has no unique function, but will in the future.

**Returns**

* [**FrameworkShared**](/api/shared)

---

### ImportPackagesInOrder

Imports the provided packages in chronological order, also allowing for you to import descendants aswell.

**Parameters**

* **importList:** `{ModuleScript}`\
A list of packages to import

* **importDeep:** `boolean?`\
Whether or not to import the package's descendants, defaults to `false`

**Returns**

* **void**

---

### Signal

Creates/reference a signal of the given name, create a new anonymous signal by leaving the name blank.

**Parameters**

* **signalName:** `string?`\
The name of the signal

**Returns**

* [**Signal**](/api/signal)

---

### CreateAnonymousSignal

Creates a new anonymous signal, this does not have a reference outside of the variable it was created in. This is essentially an alias for an empty [`CreateSignal`](#signal).

**Returns**

* [**Signal**](/api/signal)