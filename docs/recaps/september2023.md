# Engine Recap - September 2023
September 23, 2023 · 1 min read

by **[James - Lead Programmer](https://github.com/lolmansReturn)**

---

**Hi developers,**

With engine update 4.0.0, we have improved numerous aspects of the framework to make it easier to use and even more performant than before.

### New Docs Provider

Our new documentation provider, VitePress, is a more customizable and stylish website generator that we've decided to adapt too!

### Switching to Redblox

Redblox is a collection of different utility modules made by **@jackdotink**. We're migrating our networking system and signal controllers over to Red because of the performance benefits and how lightweight it is.

### New Plugin

We have completely rewritten the plugin, it is now even more efficient and better than before. It also comes with support for cloning GitHub libraries right into Roblox Studio. An explorer for it is also coming soon.

### Instance Renames & Removal of Deprecated Items

We have renamed many of the instances that Canary injects into your game to be more clear and more short. This will be useful for shortening paths especially. We have also removed all of the deprecated items:

* `EngineContext.Packages`
* `EngineContext.Media`
* `LuminFramework:GetLatestPackageVersionAsync`

### TS Support

We're back on roblox-ts! We removed it previously due to it being too hard to maintain, but it's now back for good and it functions correctly. You can locate the new TS files inside of `src/ts`.

---

If you're interested in contributing, please make a PR on our GitHub! We worked hard on this update so please give your thanks.