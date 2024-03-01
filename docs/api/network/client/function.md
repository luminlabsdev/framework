# ClientFunction <Badge type="danger" text="client" />

A client-sided network function.

## Properties

### IsReliable <Badge type="tip" text="read only" />

Whether or not the network function uses a reliable remote event.

* **boolean**

## Methods

### InvokeAsync

Invokes the server, equivalent to [RemoteFunction:InvokeServer](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction#InvokeServer). Returns a future (promise).

**Parameters**

* **data:** `...any`\
The data to invoke the server with

**Returns**

* **[Future](https://util.redblox.dev/future.html#methods)**