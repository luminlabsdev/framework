# RuntimeObjects

Used as a cache for all objects created during runtime, this includes `Signals` and `NetworkControllers`.

## Properties

### NetworkControllers

A table that stores all of the `NetworkControllers` created on the current `RunContext`.

* **{ [string]: [NetworkControllerServer](/api/network/server) | [NetworkControllerClient](/api/network/client) }**

---

### Signals

A table that stores `Signals` created on the current `RunContext`.

* **{ [string]: [Signal](/api/signal) }**