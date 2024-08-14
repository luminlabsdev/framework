# Signals

Signals are objects that you can use to communicate between different controllers. They are strikingly similar to `BindableEvents`.

## Usage

Usage for signal types can vary based on how you want the behavior to be. There are 2 kinds of signals that can be created.

### Stored Signals

Stored signals are stored in a storage table, so you can easily reference them via other modules. To get this status, you must pass a name to it.

::: code-group

```lua [Module 1]
local StoredSignal = Lumin.Signal("Stored Signal")
task.delay(3, function() -- Add delay to avoid race conditions
    StoredSignal:Fire("Hey there!")
end)
```

```lua [Module 2]
local StoredSignal = Lumin.Signal("Stored Signal")
StoredSignal:Connect(function(args)
    print(args) -- Output: Hey there!
end)
```

:::


### Anonymous Signals

Anonymous signals are not stored within the storage table, and are meant to be used usually only once.

```lua
local AnonymousSignal = Lumin.Signal()
AnonymousSignal:Connect(function(args)
    print(args) -- Output: I'm anonymous...
end)
AnonymousSignal:Fire("I'm anonymous...")
```