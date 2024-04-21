# Events

LuminFramework's event system works just as a [BindableEvent](https://create.roblox.com/docs/reference/engine/classes/BindableEvent) would, except, this method relies on the task scheduler to work which means garbage collection is easier.

### Events

Firing and connecting to events should be as simple as possible. If you are familiar with the [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal), then it should be easy enough to learn `Events`. As common knowledge, firing + listening is identical across both the `Network` library and `Event` library. Here's an example of an event being fired and connected to:

```lua
local TestEvent = LuminFramework.Event("NewEvent")

TestEvent:Connect(function(data1, data2) -- NetworkControllers use Listen instead of Connect!
    print(data1, data2) -- Output: "Hello, player"
end)

TestEvent:Fire(
    "Hello,",
    "player"
)
```

`Events` also share identical methods with the [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal), such as including `Event:Once` and even a `Event:Wait` method.

### AnonymousEvents
Anonymous events are a special type of events that can be only used from this refrence. These are events that are not stored in any way by default compared to `Event`, and are meant to be used for objects and events, and not for script communcation. They are created by using the `LuminFramework.Event` method with no name parameter. Here's an example of an anonymous event being used:

```lua
local AnonymousEvent = LuminFramework.Event()
local AnonymousEvent2 = LuminFramework.Event() -- no name conflicts!

AnonymousEvent:Connect(function(data)
    print(data) -- Output: "Signal 1"
end)

AnonymousEvent:Fire(
    "Event 1"
)

AnonymousEvent2:Connect(function(data)
    print(data) -- Output: "Signal 2"
end)

AnonymousEvent2:Fire(
    "Event 2"
)
```

Anonymous events share identical methods with `Event` so there is nothing new to learn here. 

### Connections

`Connections` are what is returned by `Events`, and it is simply a function you can call to disconnect. You can do this either by using `Signal:Connect` or `Signal:Once`, then calling the returned function which essentially acts as a `Connection:Disconnect` method.