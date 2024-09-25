# Lifecycle

Implements a lifecycle API, that will use methods from controllers that already exist.

## Properties

---

### `Name`

The name of the cycle, this will correspond with the method used.

- `string`

---

### `Listeners`

A list of the methods with the name of `Name` from each controller.

- `{ (...any) -> () }`

## Methods

---

### `Fire`

The callback function which is set to run every time the `Connection` runs.

**Parameters**

- **params:** `...any`<br>
A list of parameters to be passed to the controller method

**Returns**

- `void`
