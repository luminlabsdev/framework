# RuntimeObjects

Used as a cache for all objects created during runtime, this includes `Events` and `NetworkObjects`.

## Properties

### Network

A table that stores all of the network related `Events`/`Functions` created on the current `RunContext`.

* **{ Event: { [string]: any }, Functions: { [string]: any } }**

---

### Event

A table that stores `Events` created on the current `RunContext`.

* **{ [string]: [Event](/api/event) }**