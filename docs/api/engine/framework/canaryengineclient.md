# CanaryEngineClient <Badge type="danger" text="client" />

CanaryEngine's client-sided interface.

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

## Functions

### CreateNetworkController

Creates a new network controller on the client, with the name of `controllerName`

#### Parameters

* **controllerName:** `string`\
The name of the controller

#### Returns

* [**ClientNetworkController\<any\>**](/api/engine/types#clientnetworkcontroller)

---

### GetPlayerCharacter

Gets the players current character model; if it doesn't exist the thread will yield until it does.

#### Returns

* [**Character**](/api/engine/types#character)