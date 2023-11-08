# RuntimeObjects

Used as a cache for all objects created during runtime, this includes `Signals` and `NetworkControllers`.

## Properties

### NetworkControllers

A table that stores all of the `NetworkControllers` created on the current `RunContext`.

* **{ [string]: [NetworkControllerServer](/api/controllers/network/server) | [NetworkControllerClient](/api/controllers/network/client) }**

---

### Signals

A table that stores `Signals` created on the current `RunContext`.

* **{ [string]: [Signal](/api/controllers/signal/signal) }**