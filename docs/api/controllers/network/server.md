# NetworkControllerServer <Badge type="danger" text="server" />

A server-sided network controller, based on [this](/api/engine/types#networkcontrollerserver) type.

## Properties

### Name <Badge type="tip" text="read only" />

The name of the the network controller.

* **string**

---

### IsListening <Badge type="tip" text="read only" />

Whether or not the network controller is subscribed to an event.

* **boolean**

---

### IsBinded <Badge type="tip" text="read only" />

Whether or not the network controller is binded to any invocations.

* **boolean**

## Methods

### Fire

Fires an event which sends data to the client, equivalent to [RemoteEvent:FireClient](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent#FireClient).

:::tip
If you need to fire the event to multiple players instead of one, you can use a table of players.

```lua
NetworkController:Fire({Player1, Player2, Player3}, {1, 2, 3})
```
:::

**Parameters**

* **recipients:** `{ Player } | Player`\
The players who should recieve the data and/or call

* **data:** `(Array<any> | any)?`\
The data that should be sent to the client

**Returns**

* **void**

---

### FireAll

Fires an event which sends data to every client connected to the server, equivalent [RemoteEvent:FireAllClients](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent#FireAllClients).

**Parameters**

* **data:** `(Array<any> | any)?`\
The data that should be sent to each player

**Returns**

* **void**

---

### FireExcept

Fires an event which sends data to every client connected to the server, except for players defined in the `except` parameter.

**Parameters**

* **except:** `Array<Player> | Player`\
The players which the call should not be sent to

* **data:** `(Array<any> | any)?`\
The data that should be sent to each player except `except`

**Returns**

* **void**

---

### FireInRange

Fires an event which sends data to every client that is within `maximumRange` studs from `comparePoint`.

**Parameters**

* **comparePoint:** `Vector3`\
The point to compare from, can be a standalone `Vector3`

* **maximumRange:** `number`\
The maximum range of which the player's characters have to be within to recieve the event

* **data:** `(Array<any> | any)?`\
The data that should be sent to each player within `maximumRange`

**Returns**

* **void**

---

### FireFilter

Fires an event with a filter function, and runs the provided filter on every player in the server.

**Parameters**

* **filter:** `(Player) -> (boolean)`\
The filter to run on each player, return a boolean to indicate that the player meets the threshold

* **data:** `(Array<any> | any)?`\
The data that should be sent to each player that meets the threshold for `filter`

**Returns**

* **void**

---

### Listen

Listens for the network controller to be fired by the client, then runs the provided function.

**Parameters**

* **func:** `(sender: Player, data: Array<any>?) -> ()`\
The function to call when data is recieved

**Returns**

* **void**

---

### BindToInvocation

Recieves an invoke from the client, and runs the callback function which returns some data. Equivalent to [RemoteFunction.OnServerInvoke](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction#OnServerInvoke).

**Parameters**

* **callback:** `(sender: Player, data: Array<any>?) -> (Array<any> | any)`\
The callback function to run on invoke, must return at least 1 value.

**Returns**

* **void**

---

### SetRateLimit

Sets a rate limit that is applied when invoking or firing a network controller from the client.

**Parameters**

* **maxCalls:** `number`\
The maximum amount of invokes allowed every `interval` seconds; set to -1 to disable the rate limit

* **interval:** `number?`\
The interval of which `maxCalls` is reset

* **invokeOverflowCallback:** `((sender: Player) -> ())?`\
The callback function to run when the player has exceeded the current rate limit

**Returns**

* **void**