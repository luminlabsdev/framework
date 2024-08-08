# Worker

Responsible for handling actions on different threads concurrently

## Properties

### `Type` <Badge type="tip" text="read only" />

The type of worker defined.

- **WorkerType**

---

### `IsWorker` <Badge type="tip" text="read only" />

Whether the worker is truly a worker, this is mainly used internally.

- **boolean**

## Functions

### `Callback`

The callback function which is set to run every `WorkerType`

**Returns**

- **void**