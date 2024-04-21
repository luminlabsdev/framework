# Client <Badge type="danger" text="client" />

LuminFramework's client-sided interface.

## Properties

### Player <Badge type="tip" text="read only" />

A simple reference to the [Players.LocalPlayer](https://create.roblox.com/docs/reference/engine/classes/Players#LocalPlayer)

* [**Player**](https://create.roblox.com/docs/reference/engine/classes/Player)

---

### PlayerGui <Badge type="tip" text="read only" />

A simple reference to the [Player.PlayerGui](https://create.roblox.com/docs/reference/engine/classes/Player#PlayerGui)

* [**PlayerGui**](https://create.roblox.com/docs/reference/engine/classes/PlayerGui)

---

### PlayerBackpack <Badge type="tip" text="read only" />

A simple reference to the [Player.Backpack](https://create.roblox.com/docs/reference/engine/classes/Player#Backpack)

* [**Backpack**](https://create.roblox.com/docs/reference/engine/classes/Backpack)

---

### Network <Badge type="tip" text="read only" />

A simple reference to the network contstructor.

* [**Network**](/api/network/)

## Functions

### GetCharacter <Badge type="warning" text="yields" />

Gets the players current character model; if it doesn't exist the thread will yield until it does.

**Returns**

* [**Character**](/api/#character)