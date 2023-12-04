# FrameworkServer <Badge type="danger" text="server" />

CanaryEngine's server-sided interface.

## Functions

### NetworkController

Creates/references a network controller on the server, with the name of `controllerName`

**Parameters**

* **controllerName:** `string`\
The name of the controller

* **isUnreliable:** `boolean?`\
Whether or not the network controller is unreliable, defaults to false

**Returns**

* **[ServerNetworkController](/api/network/server)**