# FrameworkLoader

Responsible for distibuting the framework's loading screen to players, along with customization.

## Properties

### IsClientLoaded

A boolean that is true if the client is loaded.

* **boolean**

## Functions

### StartLoad

Starts up the loader, this should be run as soon as the player joins in a client script inside `ReplicatedFirst/Scripts`.

**Parameters**

* **objectsToLoad:** `{ any }`\
The objects to load, can be a list of asset id strings or instances

* **loadingMessages:** `{ [string]: Color3 }?`\
The messages to display after the loading is finished, the key is the message and the value is the color of the message

* **coreGuiEnabled:** `boolean?`\
Decides whether the CoreGui is enabled during loading

* **afterLoadWait:** `number?`\
The amount of time to wait after the load, this is before the messages in loadingMessages are shown and the loading stats are shown

* **loadingText:** `{ loadingAssetsText: string, loadedAssetsText: string }?`\
The text that should be shown when loading assets and after loading assets

**Returns**

* **void**

---

### CustomizeInterface

Allows you to customize the interface, giving you the ability to change the relevant properties. `Container` is the main frame.

**Parameters**

* **interfaceProperties:** `{ [string]: { [string]: any } }`\
The objects to load, can be a list of asset id strings or instances

**Returns**

* **void**