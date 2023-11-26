# Signal

A luau-based signal implementation.

## Methods

### Fire

Fires an event which sends data to another script that is connected to it, equivalent to [BindableEvent:Fire](https://create.roblox.com/docs/reference/engine/classes/BindableEvent#Fire)

**Parameters**

* **data:** `...any`\
The data that should be sent the other script

**Returns**

* **void**

---

### Connect

Connects a function to the event that is fired when another script fires the controller.

**Parameters**

* **func:** `(...any) -> ()`\
The function to call when data is recieved

**Returns**

* **DisconnectFunction**

---

### Once

Connects a function to the event that is fired when another script fires the controller. When using `:Once`, the function is only run the first time and then the connection is disconnected automatically.

**Parameters**

* **func:** `(...any) -> ()`\
The function to call when data is recieved

**Returns**

* **DisconnectFunction**

---

### Wait <Badge type="warning" text="yields" />

Yields the current thread until another script fires the signal controller.

**Returns**

* **...any**

---

### DisconnectAll

Disconnects all listeners from the current signal controller.

**Returns**

* **void**