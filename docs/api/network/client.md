# NetworkControllerClient <Badge type="danger" text="client" />

A client-sided network controller.

## Properties

### IsListening <Badge type="tip" text="read only" />

Whether or not the network controller is subscribed to an event.

* **boolean**

---

### IsReliable <Badge type="tip" text="read only" />

Whether or not the network controller uses a reliable remote event or not.

* **boolean**

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

* **data:** `...any`\
The data that should be sent to the server

**Returns**

* **void**

---

### InvokeAsync

Invokes the server, equivalent to [RemoteFunction:InvokeServer](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction#InvokeServer). Returns a promise.

**Parameters**

* **data:** `...any`\
The data to invoke the server with

**Returns**

* **[Future](https://util.redblox.dev/future.html#methods)**

---

### Listen

Listens for the network controller to be fired by the server, then runs the provided function. Note that this can only be run once, it will error if run more than once.

**Parameters**

* **func:** `(...: any) -> ()`\
The function to call when data is recieved

**Returns**

* **void**