# Setup

To successfully kick off your new Lumin project, we recommend using SSA (single script architecture). The framework was designed for this type of architecture and hence is most compatible with it.

## Organization

Organization is a vital part of a successful game! First and foremost, you should be placing the LuminFramework package within `ReplicatedStorage` so the client and server can both access it. After you sort that out, place a server and client script inside `ReplicatedStorage` and `ServerStorage` respectively (this example uses `RunContext` but there is fundamentally no difference). After, create a `Modules` folder in `ReplicatedStorage` and `ServerStorage` along with a `Shared` folder in `ReplicatedStorage` as well for modules where the run context does not matter.

## Start

Setting up the framework is identical on both client and server scripts, with the only change being the module directories. An example is seen below:

```luau
local Lumin = require(path.to.luminframework)
local Modules = require(game:GetService("ReplicatedStorage").Modules) -- Points to Shared, Client or Server modules
Lumin.Start({
    Modules, -- You can add more directories to this table which the children will be loaded
})
```

## Recommended Packages

A list of other open sourced libraries that pair quite well with the framework.

`dphfox/fusion`<br>
`lumin/net`<br>
`sleitnick/trove`

These are for most basic games but you can remove or include others as you please!
