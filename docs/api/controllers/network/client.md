# NetworkControllerClient <Badge type="danger" text="client" />

A client-sided network controller, based on [this](/api/engine/types#networkcontrollerclient) type.

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

**Parameters**

* **data:** `Array<any> | any`\
The data that should be sent to the server

**Returns**

* **void**

---

### InvokeAsync

Invokes the server, equivalent to [RemoteFunction:InvokeServer](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction#InvokeServer). Returns a promise.

**Parameters**

* **data:** `Array<any> | any`\
The data to invoke the server with

**Returns**

* **[Future](https://util.redblox.dev/future.html#methods)**

---

### Listen

Listens for the network controller to be fired by the server, then runs the provided function.

**Parameters**

* **func:** `(data: Array<any>) -> ()`\
The function to call when data is recieved

**Returns**

* **void**