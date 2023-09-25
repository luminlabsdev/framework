# CanaryEngineServer <Badge type="danger" text="server" />

CanaryEngine's server-sided interface.

## Properties

### Data <Badge type="tip" text="read only" />

Access to the [EasyProfile](/api/libraries/data/easyprofile) library.

* **[EasyProfile](/api/libraries/data/easyprofile)**

## Functions

### CreateNetworkController

Creates a new network controller on the server, with the name of `controllerName`

**Parameters**

* **controllerName:** `string`\
The name of the controller

**Returns**

* **[ServerNetworkController](/api/controllers/network/server)**