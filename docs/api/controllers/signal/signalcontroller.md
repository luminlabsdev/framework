# SignalController

A lua-based signal implementation, based on [this](/api/engine/types#signalcontroller) type.

## Properties

### Name <Badge type="tip" text="read only" />

The name of the the signal controller.

* **string**

## Methods

### Fire

Fires an event which sends data to another script that is connected to it, equivalent to [BindableEvent:Fire](https://create.roblox.com/docs/reference/engine/classes/BindableEvent#Fire)

:::tip
If you're firing a single piece of data, there is no need to wrap it in a table!

```lua
SignalController:Fire("Hello, world!")
```
:::

**Parameters**

* **data:** `(Array<any> | any)?`\
The data that should be sent the other script

**Returns**

* **void**

---

### Connect

Connects a function to the event that is fired when another script fires the controller.

**Parameters**

* **func:** `(data: Array<any>?) -> ()`\
The function to call when data is recieved

**Returns**

* **[ControllerConnection](/api/engine/types#controllerconnection)**

---

### Once

Connects a function to the event that is fired when another script fires the controller. When using `:Once`, the function is only run the first time and then the connection is disconnected automatically.

**Parameters**

* **func:** `(data: Array<any>?) -> ()`\
The function to call when data is recieved

**Returns**

* **[ControllerConnection](/api/engine/types#controllerconnection)**

---

### Wait <Badge type="warning" text="yields" />

Yields the current thread until another script fires the signal controller.

**Returns**

* **[Array](/api/engine/types#array)\<any\>**

---

### DisconnectAll

Disconnects all listeners from the current signal controller.

**Returns**

* **void**