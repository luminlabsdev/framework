---
sidebar-position: 2
---

# Signals

CanaryEngine's signal system is essentially the successor of the well-known [BindableEvent](https://create.roblox.com/docs/reference/engine/classes/BindableEvent), but no special quirks come with it. Some of these issues include common memory leaks and overall slowness. Our signal implementation simply uses **[@stravant](https://github.com/stravant)**'s signal implementation which solely relies on the task scheduler to work.

### ScriptSignals

Firing and connecting to signals should be as simple as possible. If you are familiar with the [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal), then it should be easy enough to learn `ScriptSignal`'s. As common knowledge, firing + connecting is identical across both the `NetworkController` and `ScriptSignal`. Here's an example of an event being fired and connected to:

```lua
local TestSignal = CanaryEngine.CreateSignal("NewSignal")

TestSignal:Connect(function(data)
    print(data) -- Output: {"Hello,", "player"}
end)

TestSignal:Fire({
    "Hello,",
    "player"
})
```

`ScriptSignals` also share identical methods with the [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal), such as including `ScriptSignal:Once` and even a `ScriptSignal:Wait` method. Though, an extra feature that comes with using **[@stravant](https://github.com/stravant)**'s signal implementation is that you have the ability to disconnect every connection associated with the signal. This allows for quick cleanups of a signal. 

### ScriptConnections

`ScriptConnection`'s are what is returned by `ScriptSignal`'s, these allow you to check the current connection status with `ScriptConnection.Connected` and allow you to disconnect any connections you made, either by using `ScriptSignal:Connect` or `ScriptSignal:Once`, by using the `ScriptConnection:Disconnect` method. These are identical to the [RBXScriptConnection](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection), so documentation isn't really needed with this.

That's really all for `ScriptSignals`, they are a fairly simple concept and are extremely useful in many varied ways.