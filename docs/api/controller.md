# Controller

Responsible for controlling most of the game's functions

## Properties

### `Name`

The name of the controller.

- **string?**

---

### `IsController`

Whether the controller is truly a controller, this is mainly used internally.

- **boolean?**

## Functions

### `Init`

Prepares the controller so that it can be used across the data model.

**Returns**

- **void**

---

### `Start`

Called internally when the controller is safe to use other dependencies that were prepared previously by `Init`.

**Returns**

- **void**