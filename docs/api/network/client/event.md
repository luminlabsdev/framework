# ClientEvent <Badge type="danger" text="client" />

A client-sided network event.

## Properties

### IsReliable <Badge type="tip" text="read only" />

Whether or not the network event uses a reliable remote event.

* **boolean**

## Methods

### Fire

Fires an event which sends data to the server, equivalent to [RemoteEvent:FireServer](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent#FireServer)

**Parameters**

* **data:** `...any`\
The data that should be sent to the server

**Returns**

* **void**

---

### Listen

Listens for the network controller to be fired by the server, then runs the provided function. Note that this can only be run once, it will error if run more than once.

**Parameters**

* **func:** `(...: any) -> ()`\
The function to call when data is recieved

**Returns**

* **void**