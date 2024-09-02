# Controller

Responsible for controlling most of the game's functions

## Properties

---

### `Uses`

Any other controllers that the current one uses

- **{ Controller }**

## Functions

---

### `Init`

Prepares the controller so that it can be used across the data model.

**Returns**

- **void**

---

### `Start`

Called internally when the controller is safe to use other dependencies that were prepared previously by `Init`.

**Returns**

- **void**
