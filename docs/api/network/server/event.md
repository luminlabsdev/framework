# ServerEvent <Badge type="danger" text="server" />

A server-sided network event.

## Properties

### IsReliable <Badge type="tip" text="read only" />

Whether or not the network event uses a reliable remote event.

* **boolean**

## Methods

### Fire

Fires an event which sends data to the client, equivalent to [RemoteEvent:FireClient](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent#FireClient).

:::tip
If you need to fire the event to multiple players instead of one, you can use a table of players.

```lua
NetworkController:Fire({Player1, Player2, Player3}, 1, 2, 3)
```
:::

**Parameters**

* **recipients:** `{ Player } | Player`\
The players who should recieve the data and/or call

* **data:** `...any`\
The data that should be sent to the client

**Returns**

* **void**

---

### FireAll

Fires an event which sends data to every client connected to the server, equivalent [RemoteEvent:FireAllClients](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent#FireAllClients).

**Parameters**

* **data:** `...any`\
The data that should be sent to each player

**Returns**

* **void**

---

### FireExcept

Fires an event which sends data to every client connected to the server, except for players defined in the `except` parameter.

**Parameters**

* **except:** `{ Player } | Player`\
The players which the call should not be sent to

* **data:** `...any`\
The data that should be sent to each player except `except`

**Returns**

* **void**

---

### FireFilter

Fires an event with a filter function, and runs the provided filter on every player in the server.

**Parameters**

* **filter:** `(Player) -> (boolean)`\
The filter to run on each player, return a boolean to indicate that the player meets the threshold

* **data:** `...any`\
The data that should be sent to each player that meets the threshold for `filter`

**Returns**

* **void**

---

### Listen

Listens for the network controller to be fired by the client, then runs the provided function.

**Parameters**

* **func:** `(sender: Player, data: ...: unknown) -> ()`\
The function to call when data is recieved

* **typeValidationArgs:** `{ string }?`\
A table of the valid types that should be recieved by the client. This is optional.

**Returns**

* **void**

---

### SetRateLimit

Sets a rate limit that is applied when firing a network event from the client.

**Parameters**

* **maxCalls:** `number`\
The maximum amount of invokes allowed every `interval` seconds; set to -1 to disable the rate limit

* **resetInterval:** `number?`\
The interval of which `maxCalls` is reset

* **fireOverflowCallback:** `(sender: Player) -> ()?`\
The callback function to run when the player has exceeded the current rate limit

**Returns**

* **void**