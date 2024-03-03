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

---

### SetRateLimit

Sets a rate limit that is applied when invoking the network function from the client.

**Parameters**

* **maxCalls:** `number`\
The maximum amount of invokes allowed every `interval` seconds; set to -1 to disable the rate limit

* **resetInterval:** `number?`\
The interval of which `maxCalls` is reset

* **invokeOverflowCallback:** `(sender: Player) -> ()?`\
The callback function to run when the player has exceeded the current rate limit

**Returns**

* **void**