# Client <Badge type="danger" text="client" />

The framework's client-sided interface.

## Properties

### Player <Badge type="tip" text="read only" />

A simple reference to the [Players.LocalPlayer](https://create.roblox.com/docs/reference/engine/classes/Players#LocalPlayer)

* [**Player**](https://create.roblox.com/docs/reference/engine/classes/Player)

---

### PlayerGui <Badge type="tip" text="read only" />

A simple reference to the [Player.PlayerGui](https://create.roblox.com/docs/reference/engine/classes/Player#PlayerGui)

* [**PlayerGui**](https://create.roblox.com/docs/reference/engine/classes/PlayerGui)

---

### Network <Badge type="tip" text="read only" />

A simple reference to the network contstructor.

* [**Network**](/api/network/)

## Functions

### Character

Gets the players current character model; if it doesn't exist the thread will yield until it does.

**Returns**

* [**Promise**](https://eryn.io/roblox-lua-promise/)<[**Character**](/api/#character)>