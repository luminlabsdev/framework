# Signals

Signals are an object that allows you to communicate across scripts easily. Think bindable events but in a much more optimized Luau form. These signal objects are automatically garbage collected and have a few more utility functions that come with. You can create a signal by running the `Framework.Signal` function. Leave the name blank to create a signal that has no reference in the framework and can only be used locally.

```lua
local Framework = require(ReplicatedStorage.Packages.Framework)
local MySignal = Framework.Signal("MySignal") -- will have a reference internally because a name was passed

MySignal:Connect(function(str)
    print(str) -- Output: Hello!
end)
MySignal:Fire("Hello!")
```