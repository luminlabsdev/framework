# Setup

To setup the framework, it is minimally recommended that you use `.Start` which makes everything start working. I'll leave this guide short and sweet, so here is some example code to help you get started:

```lua
local Lumin = require(path.to.luminframework)
local Modules = require(game:GetService("ReplicatedStorage").Modules)
Lumin.Start(Modules):andThen(function()
    print("Framework has started!")
end)
```