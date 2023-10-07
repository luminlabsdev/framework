# Signals

CanaryEngine's signal system is essentially the successor of the well-known [BindableEvent](https://create.roblox.com/docs/reference/engine/classes/BindableEvent), but no special quirks come with it. Some of these issues include common memory leaks and overall slowness. Our signal implementation simply uses **[@stravant](https://github.com/stravant)**'s signal implementation which solely relies on the task scheduler to work.

### SignalControllers

Firing and connecting to signals should be as simple as possible. If you are familiar with the [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal), then it should be easy enough to learn `SignalController`'s. As common knowledge, firing + connecting is identical across both the `NetworkController` and `SignalController`. Here's an example of an event being fired and connected to:

```lua
local TestSignal = CanaryEngine.CreateSignal("NewSignal")

TestSignal:Connect(function(data1, data2)
    print(data1, data2) -- Output: "Hello, player"
end)

TestSignal:Fire(
    "Hello,",
    "player"
)
```

`SignalController` also share identical methods with the [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal), such as including `SignalController:Once` and even a `SignalController:Wait` method. Though, an extra feature that comes with using **[@stravant](https://github.com/stravant)**'s signal implementation is that you have the ability to disconnect every connection associated with the signal. This allows for quick cleanups of a signal. 

### AnonymousSignals
Anonymous signals are a special type of signal that can be only used from this refrence. These are signals that are not stored in any way by default compared to `SignalController`, and are meant to be used for objects and events, and not for script communcation. They are created by using the `CanaryEngine.CreateAnonymousSignal` method. Here's an example of an anonymous signal being used:

```lua
local AnonymousSignal = CanaryEngine.CreateAnonymousSignal()
local AnonymousSignal2 = CanaryEngine.CreateAnonymousSignal() -- no name conflicts!

AnonymousSignal:Connect(function(data)
    print(data) -- Output: "Signal 1"
end)

AnonymousSignal:Fire(
    "Signal 1"
)

AnonymousSignal2:Connect(function(data)
    print(data) -- Output: "Signal 2"
end)

AnonymousSignal2:Fire(
    "Signal 2"
)
```

Anonymous signals share identical methods with `SignalController` so there is nothing new to learn here. 

### ControllerConnections

`ControllerConnection`'s are what is returned by `SignalController`'s, and it is simply a function you can call to disconnect. You can do this either by using `SignalController:Connect` or `SignalController:Once`, then calling the returned function.