# Networking

CanaryEngine's networking system is very straightforward compared to some of the other game frameworks out there. It uses a method which reduces bandwidth by a lot, and in turn will help your game lag less. This document serves as a simple tutorial on the networking system, explaining all the functionality available in the `NetworkController`.

### RemoteEvents

Instead of interacting with the normal [RemoteEvent](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) API, we use a custom method which is much more compatible with many game's standards. Though, to first create a new controller, use the `.CreateNetworkController` function in the context specific framework. In this tutorial, we assume the server is trying to send information to the client. Here's an example of how you would set up the network controller:

::: code-group
```lua [Server]
local SendInfoNetwork = CanaryEngineServer.CreateNetworkController("SendInfoNetwork")

print(SendInfoNetwork.Name) -- Output: SendInfoNetwork
```

```lua [Client]
local SendInfoNetwork = CanaryEngineClient.CreateNetworkController("SendInfoNetwork")
```
:::

Now lets continue this code and make it so it can recieve info from the server:

::: code-group
```lua [Server]
local SendInfoNetwork = CanaryEngineServer.CreateNetworkController("SendInfoNetwork")
local PlayerService = game:GetService("Players")

print(SendInfoNetwork.Name) -- Output: SendInfoNetwork

SendInfoNetwork:FireAll({ -- When sending data on the server, you must pass a player argument. In this example though, we are firing to all players.
    "Sent through a",
    "Network controller!"
})
```

```lua [Client]
local SendInfoNetwork = CanaryEngineClient.CreateNetworkController("SendInfoNetwork")

SendInfoNetwork:Listen(function(data)
    print(data)
end)
```
:::

:::danger
You cannot really create a replicated network controller. This is because it would be accessed both by the server/client, so you would have to explicity check if is the server or client. This is considered a bad practice anyway, you shouldn't be using server or client exclusive things with shared packages.
:::

When we start the script, we should then see the the name in the output, and also see the following in the client output:

```lua
{
    "Sent through a",
    "Network controller!"
}
```

Please keep in mind that these can be used for many other things other than just passing strings through, also that if you just have a single piece of data you can send it through the fire method without wrapping it in a table. Though, keep in mind that the data you recieve will always be a table no matter how you pass the data originally.

:::danger
You can in fact pass dictionaries through fire functions, but keep in mind these are bandwith-heavy and should be arrays instead.
:::

We also have available the `Fire`, `FireExcept` and `SetRateLimit` functions. Each of them are documented in their own API page.

### RemoteFunctions

The [RemoteFunction](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction) is a fairly straightforward way of sending and recieving data at the same time. For now, we only support invoking the server as invoking the client is fairly useless at this point. If you need this functionality, you can use the remote event part of the network controllers. You may already know how to set up the basic network controller, so here's just a basic example of the client asking the server for a value:

::: code-group
```lua [Server]
local ValueGetNetwork = CanaryEngineServer.CreateNetworkController("ValueGetNetwork")

ValueGetNetwork:BindToInvocation(function(sender, data)
    print(sender.Name) -- The player who sent the invoke's name
    if data[1] then
        return "yes" -- We must return a value here, or it will error
    else
        return "no"
    end
end)
```

```lua [Client]
local ValueGetNetwork = CanaryEngineClient.CreateNetworkController("ValueGetNetwork")

print(ValueGetNetwork:InvokeAsync(true)) -- When the value is recieved, this should return "yes" according to the server code.
```
:::

Obviously, this isn't quite a valid use case for invoking the server, but some valid use cases include asking the server for a specific value. What we are doing here is just a waste of bandwidth, but for the sake of the tutorial I will be including this.