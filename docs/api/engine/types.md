# EngineTypes

Types used by the engine for objects.

## Types

### ControllerConnection <Badge type="tip" text="private" />

What is returned after using `Connect` or `Once` on a [SignalController](/api/controllers/signal/signalcontroller)

---

### SignalController <Badge type="tip" text="public" />

A signal controller, similar to an [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal)

---

### Character <Badge type="tip" text="public" />

A basic type of an R6 character rig. Should be combined with model using the `&` syntax.

---

### ServerNetworkController <Badge type="tip" text="public" />

A ServerNetworkController is basically a mixed version of a [RemoteEvent](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) and [RemoteFunction](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction). It has better features and is more performant, though this is the server-sided API.

---

### ClientNetworkController <Badge type="tip" text="public" />

A ClientNetworkController is basically a mixed version of a [RemoteEvent](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) and [RemoteFunction](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction). It has better features and is more performant.

---

### Array <Badge type="tip" text="public" />

A simple array type.

---

### Dictionary <Badge type="tip" text="public" />

A simple dictionary type.