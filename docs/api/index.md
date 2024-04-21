# LuminFramework (Root)

The main class of LuminFramework.

## Properties

### Runtime <Badge type="tip" text="read only" />

The runtime property contains settings that are set during runtime, and the current context of the server/client.

* [**Runtime**](/api/runtime/)

---

### Debugger <Badge type="tip" text="read only" />

The internal engine debugger, has useful functions to abide by debug settings.

* [**Debugger**](/api/debugger)

---

### LoadTime <Badge type="tip" text="read only" />

The number in seconds of which the framework took to completely finish loading, this property is not rounded.

* **number**

## Functions

### Server <Badge type="danger" text="server" />

Gets the server-sided interface of LuminFramework.

**Returns**

* [**Server**](/api/server)

---

### Client <Badge type="danger" text="client" /> <Badge type="warning" text="yields" />

Gets the client-sided interface of LuminFramework.

**Returns**

* [**Client**](/api/client)

---

### ImportPackages

Imports the provided packages in chronological order, also allowing for you to import descendants aswell. Non-modules will be filtered out automatically.

**Parameters**

* **importList:** `{ModuleScript}`\
A list of packages to import

* **importDeep:** `boolean?`\
Whether or not to import the package's descendants, defaults to `false`

**Returns**

* **void**

---

### Event

Creates/reference a event of the given name, create a new anonymous event by leaving the name blank.

**Parameters**

* **name:** `string?`\
The name of the event

**Returns**

* [**Event**](/api/event)