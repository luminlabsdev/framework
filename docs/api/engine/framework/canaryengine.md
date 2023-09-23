# CanaryEngine

The main class of CanaryEngine.

## Properties

### Runtime <Badge type="tip" text="read only" />

The runtime property contains settings that are set during runtime, and the current context of the server/client.

* [**EngineRuntime**](/api/engine/runtime/engineruntime)

---

### Debugger <Badge type="tip" text="read only" />

The internal engine debugger, has useful functions to abide by debug settings.

* [**EngineDebugger**](/api/engine/dependencies/enginedebugger)

## Functions

### GetEngineServer <Badge type="danger" text="server" />

Gets the server-sided interface of CanaryEngine.

#### Returns

* [**CanaryEngineServer?**](/api/engine/framework/canaryengineserver)

---

### GetEngineClient <Badge type="danger" text="client" /> <Badge type="warning" text="yields" />

Gets the client-sided interface of CanaryEngine.

#### Returns

* [**CanaryEngineClient?**](/api/engine/framework/canaryengineclient)

---

### GetEngineReplicated

Gets the global-sided interface of CanaryEngine. Recommended that use this only in replicated packages, this is a bad practice anywhere else.

#### Returns

* [**CanaryEngineRepliated?**](/api/engine/framework/canaryenginereplicated)

---

### CreateSignal

Creates a new signal that is then given a reference in the signals table. Create a new anonymous signal by leaving the name blank.

#### Parameters

* **signalName:** `string?`\
The name of the signal

#### Returns

* [**SignalController\<any\>**](/api/engine/types#signalcontroller)

---

### CreateAnonymousSignal

Creates a new anonymous signal, this does not have a reference outside of the variable it was created in. This is essentially an alias for an empty [`CreateSignal`](#createsignal)

#### Returns

* [**SignalController\<any\>**](/api/engine/types#signalcontroller)