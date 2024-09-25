---
hide:
  - toc
  - navigation
---

A lightning fast & efficient framework for Roblox, inspired by Prvd 'M Wrong.

[Guides](./guides/){ .md-button .md-button--primary }
[Reference](./reference/){ .md-button }

## Easily Create Controllers

```luau
local Framework = require(Packages.framework)

local function Explode()
    print("KABOOM!!!")
end

return Framework.New {
    Explode = Explode,
}
```

Boasts an efficent controller API, which is not verbose and uncomplicated.

## Organized Dependencies

```luau
local Framework = require(Packages.framework)
local Dependency = require(Modules.Dependency)

-- Init is called after other dependencies the module uses are loaded
local function Init()
    Dependency.NuclearExplosion() -- This dependency loads first and in result is usable!
end

return Framework.New {
    Uses = { Dependency },
    Init = Init,
}
```

Organizes your dependencies in an understandable way, so you can easily keep track of what your module uses.

## Straightforward Cycle Design

```luau
local Framework = require(Packages.framework)
local FrameLifecycle = Framework.Lifecycle("Frame")

local function Frame()
    print("I print every frame!")
end

return Framework.New {
    Frame = Frame,
}
```

Has a simple lifecycle design that is readable and accessible at a glance.

## Finally...

Try it out and see if you love it! It comes in a very small size and is easily embeddable into already existing game architecture; *no* extra dependencies are required. With built-in plugin support, a thriving community, and type safety, what's truly **not** to like about it?
