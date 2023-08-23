# Debugger

The debugger is a library used internally by CanaryEngine. It allows you to respect debug settings set by the user, while also allowing to do useful things like get a detailed call stack of a script any time, and cause quick type errors during run time.

### Simple Debugging

On the basic side, the `Debugger.Debug` function will allow you to provide some sort of handler, example of this could be `print` or `error`, then you can supply messages in either a table or just a single value. You can also provide a custom prefix and choose whether or not to respect the debugger settings (Recommended on at all times). Here's a basic example of a print message:

```lua
Debugger.Debug(print, {"Hello!", "it's", "me!"}) -- Output: [Debugger]: Hello! it's me!
```

Once again, this function will respect the `LiveGameDebugger` and `StudioDebugger` settings. `LiveGameDebugger` is off by default and can be toggled via framework install settings or by using the attribute on the folder itself.

### Call Stack / Type Errors

Another cool feature of the debug library is that you can get a full and quite detailed call stack, from the line it was called from to the cleaned up path to the script/package and the name you provided. Here's a basic example where you would place your script inside of `EngineClient.Scripts`:

```lua
print(Debugger.GetCallStack(script, "MyStack")) -- Output: { ["DefinedLine"] = 19, ["Name"] = "MyStack", ["Source"] = "EngineClient.Scripts.ClientScript" }
```

The last feature of the debugger library is that you can create type errors that mimic Luau's with ease. Here's an example of how you would generate one and what it would produce:

```lua
Debugger.DebugInvalidData(1, "MyFunction", "Vector3", paramThatErrored) -- Output (Error): invalid argument #1 to 'MyFunction' (Vector3 expected, got number)
```