# EngineRuntimeObjects

Used as a cache for all objects created during runtime, this includes `Signals` and `NetworkControllers`.

## Properties

### NetworkControllers

A table that stores all of the `NetworkControllers` created on the current `RunContext`.

* **[NetworkControllerServer](/api/controllers/network/server) | [NetworkControllerClient](/api/controllers/network/client)**

---

### Signals

A table that stores `Signals` created on the current `RunContext`.

* **[Signal](/api/controllers/signal/signalcontroller)**