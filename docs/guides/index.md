# Setup

To start, we recommend using SSA (single script architecture) to kick off your new project using Lumin. No start function needed, all you need to do is import the main module from your `Packages` folder and you're done.

:::warning
A server script is required to start the framework due to networking, a client script is optional
:::

## Loading Modules

To load a module, you need to run the `Framework.Load` function providing the parent folder or object, and optionally pass a filter function through as well.

```lua
local Framework = require(ReplicatedStorage.Packages.Framework)
Framework.Load(ReplicatedStorage.Modules, function(module)
    if module.Name:find("turkey") then
        return true
    end
end) -- filter can be as complex as you want it to be
```

## Finding Server/Client Interfaces

The server and client interfaces can be accessed via the `.Server` and `.Client` functions. Keep in mind that neither of these will work if you are not running the parent script on the correct run context.

```lua
local Framework = require(ReplicatedStorage.Packages.Framework)
local Server = Framework.Server() -- or Framework.Client()
```
From here, you can access run context specific items like the player gui.

## Recommended Packages

To start a successful project, we recommend using:

`lumin/aegis`\
`sleitnick/trove`

... and of course Lumin Framework.