# ServerFunction <Badge type="danger" text="server" />

A server-sided network function.

## Properties

### IsReliable <Badge type="tip" text="read only" />

Whether or not the network function uses a reliable remote event.

* **boolean**

## Methods

### OnInvoke

Recieves an invoke from the client, and runs the callback function which returns some data. Equivalent to [RemoteFunction.OnServerInvoke](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction#OnServerInvoke).

**Parameters**

* **callback:** `(sender: Player, ...: unknown) -> (any, ...any)`\
The callback function to run on invoke, must return at least 1 value.

**Returns**

* **void**