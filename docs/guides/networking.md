# Networking

LuminFramework's networking system is very straightforward compared to some of the other game frameworks out there. It uses a method which reduces bandwidth by a lot, and in turn will help your game lag less. This document serves as a simple tutorial on the networking system, explaining all the functionality available in the `Network` constructor.

### Events

Instead of interacting with the normal [RemoteEvent](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) API, we use a custom method which is much more compatible with many game's standards. To create/reference a new event/function, use the `.Network` property in the context specific interface and then create/reference either an Event or Function. In this tutorial, we assume the server is trying to send information to the client. Here's an example of how you would set up the network event:

::: code-group
```lua [Server]
local SendInfoNetwork = Server.Network.Event("SendInfo")
```

```lua [Client]
local SendInfoNetwork = Client.Network.Event("SendInfo")
```
:::

Now lets continue this code and make it so it can recieve info from the server:

::: code-group
```lua [Server]
local SendInfoNetwork = Server.Network.Event("SendInfo")
local PlayerService = game:GetService("Players")

SendInfoNetwork:FireAll( -- When sending data on the server, you must pass a player argument. In this example though, we are firing to all players.
    "Sent through a",
    "network event!"
)
```

```lua [Client]
local SendInfoNetwork = Client.Network.Event("SendInfo")

SendInfoNetwork:Listen(function(data1, data2)
    print(data1, data2)
end)
```
:::

:::danger
You cannot really create a replicated event/function. This is because it would be accessed both by the server/client, so you would have to explicity check if is the server or client. This is considered a bad practice anyway, you shouldn't be using server or client exclusive things with shared packages.
:::

When we start the script, we should then see the the name in the output, and also see the following in the client output:

```lua
"Sent through a network event!"
```

Please keep in mind that these can be used for many other things other than just passing strings through, also that if you just have a single piece of data you can send it through the fire method without wrapping it in a table. Though, keep in mind that the data you recieve will always be a table no matter how you pass the data originally.

:::danger
You can in fact pass dictionaries through fire functions, but keep in mind these are bandwith-heavy and should be arrays instead.
:::

### Functions

The [RemoteFunction](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction) is a fairly straightforward way of sending and recieving data at the same time. For now, we only support invoking the server as invoking the client is fairly useless at this point. If you need this functionality, you can use the remote event part of the network library. You may already know how to set up the basic event, so creating a function is fairly similar:

::: code-group
```lua [Server]
local ValueGetNetwork = Server.Network.Function("ValueGet")

ValueGetNetwork:OnInvoke(function(sender, data)
    print(sender.Name) -- The player who sent the invoke's name
    if data then
        return "yes" -- We must return a value here, or it will error
    else
        return "no"
    end
end)
```

```lua [Client]
local ValueGetNetwork = Client.Network.Function("ValueGet")

print(ValueGetNetwork:InvokeAsync(true):Await()) -- When the value is recieved, this should return "yes" according to the server code.
```
:::

Obviously, this isn't quite a valid use case for invoking the server, but some valid use cases include asking the server for a specific value. What we are doing here is just a waste of bandwidth and should only be used for tests.

### Type Validation

Type validation was a feature that was released in v6.2.1. Type validation allows you to force the client to send specific types in a specific order. If these types do not match up to what the server declared, the packet will be dropped/ignored and a warning will be in the server output. We may allow custom callbacks in the future although it currently isn't needed. To start with type validation, create a new network event or function and use the `Listen` function as normal.

::: code-group
```lua [Server]
local TypeValidationTestNetwork = Server.Network.Event("TypeValidationTest")

ValueGetNetwork:Listen(function(arg1, arg2, arg3)
    print(arg1, arg2, arg3)
end)
```

```lua [Client]
local TypeValidationTestNetwork = Client.Network.Event("TypeValidationTest")

task.delay(5, function()
    TypeValidationTestNetwork:Fire("turkey", 1, true)
end)
```
:::

The above will function normally just like how a default network event would. To activate the type validation, add another argument to `Listen` that is a table, these will contain the types.

```lua
local TypeValidationTestNetwork = Server.Network.Event("TypeValidationTest")

ValueGetNetwork:Listen(function(arg1, arg2, arg3)
    print(arg1, arg2, arg3)
end, {"string", "number", "boolean"})
```
For type validation to work properly, these should be in the exact same order as you would expect the arguments to. The above example is how the server expects it to be, so nothing would happen and the listener would run as normal. Now, lets change up the order of the arguments on the client and see what happens. 

```lua
local TypeValidationTestNetwork = Client.Network.Event("TypeValidationTest")

task.delay(5, function()
    TypeValidationTestNetwork:Fire("turkey", true, 1)
end)
```
What happens now is the listener on the server will not run and we instead get a warning in the output. In this scenario, your warning should look similar to this:

`[Network] Argument #2 does not have the type 'number'`