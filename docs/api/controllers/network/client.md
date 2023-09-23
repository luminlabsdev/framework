# NetworkControllerClient

A client-sided network controller.

## Properties

### Name <Badge type="tip" text="read only" />

The name of the the network controller.

* **string**

## Methods

### Fire

Fires an event which sends data to the server, equivalent to [RemoteEvent:FireServer](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent#FireServer)

:::tip
If you're firing a single piece of data, there is no need to wrap it in a table!

```lua
NetworkController:Fire("Hello, world!")
```
:::

#### Parameters

* **data:** `{ any } | any`\
The data that should be sent to the server

#### Returns

* **void**

---

### InvokeAsync

Invokes the server, equivalent to [RemoteFunction:InvokeServer](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction#InvokeServer). Returns a promise.

#### Parameters

* **data:** `{ any } | any`\
The data to invoke the server with

#### Returns

* **Promise**

---

### Connect

Connects a function to the event that is fired when the server fires the network controller.

#### Parameters

* **func:** `( data: { any } ) -> ()`\
The function to call when data is recieved

#### Returns

* **void**

---

### Wait

Yields the current thread until the server fires the network controller. Returns a promise.

#### Returns

* **Promise**