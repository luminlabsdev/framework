# Signals

CanaryEngine's signal system works just as a [BindableEvent](https://create.roblox.com/docs/reference/engine/classes/BindableEvent) would, except, this method relies on the task scheduler to work which means garbage collection is easier.

### Signals

Firing and connecting to signals should be as simple as possible. If you are familiar with the [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal), then it should be easy enough to learn `Signal`'s. As common knowledge, firing + listening is identical across both the `NetworkController` and `Signal`. Here's an example of an event being fired and connected to:

```lua
local TestSignal = CanaryEngine.CreateSignal("NewSignal")

TestSignal:Connect(function(data1, data2) -- NetworkControllers use Listen instead of Connect!
    print(data1, data2) -- Output: "Hello, player"
end)

TestSignal:Fire(
    "Hello,",
    "player"
)
```

`Signal`'s also share identical methods with the [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal), such as including `Signal:Once` and even a `Signal:Wait` method.

### AnonymousSignals
Anonymous signals are a special type of signal that can be only used from this refrence. These are signals that are not stored in any way by default compared to `Signal`, and are meant to be used for objects and events, and not for script communcation. They are created by using the `CanaryEngine.CreateAnonymousSignal` method. Here's an example of an anonymous signal being used:

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

Anonymous signals share identical methods with `Signal` so there is nothing new to learn here. 

### Connections

`Connection`'s are what is returned by `Signal`'s, and it is simply a function you can call to disconnect. You can do this either by using `Signal:Connect` or `Signal:Once`, then calling the returned function.