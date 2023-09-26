---
title: Changelog
description: The changelog for CanaryEngine
keywords: [roblox, game, framework, changelog, updates]
---

# Changelog

This is the changelog which is changed every update, and we follow semver. To see what we're working on, head to our [Trello](https://trello.com/b/fTJOmMua/canaryengine) board.

## 4.0.0-rc1

### Added

* Adds `Red`, revamped the networking system once again and for the last time
* Revamped plugin for last time, easier to navigate / add features
* Adds ability to pull packages from any GitHub repo
* Entirely new documentation provider

### Improvements

* Improves EasyProfile ([#3](https://github.com/canary-development/CanaryEngine/pull/3), [koxx12](https://github.com/koxx12-dev))
* Renames `CanaryEngineFramework` instance to `Framework`
* Renames `CanaryEngine` module to `Init`
* Fixed TS support, back on roblox-ts!
* Small bug fixes
* QOL fixes
* Most yielding functions now make usage of Futures

### Removed

* `BridgeNet`
* `EngineContext.Packages`
* `EngineContext.Media`

## 3.3.5

### Added

* 2 new debugger functions
* UIShelf library
* Documentation blog page

### Improvements

* Improve `networkControllerTimeout`
* Improve API docs
* Improve tutorials, 4 new
* Improve types
* Improve performance

### Removed

Nothing!

## 3.2.5

No information available, mainly small bug fixes.

## 3.2.4

### Added

* `AnonymousSignals` ([#2](https://github.com/canary-development/CanaryEngine/pull/2), [koxx12](https://github.com/koxx12-dev))
* `EngineReplicatedFirst`
* Add new default loading screen

### Improvements

* Fix all plugin bugs, now runs faster
* Fix signals erroring constantly
* Fix small bugs
* Improve typings
* Updated Benchmark + Debugger modules

### Removed

Nothing!

## 3.1.4

### Added

* Native `roblox-ts` support
* Docs for all APIs
* Plugin now updates all files dynamically

### Improvements

* Improves default structure
* Improved plugin

### Removed

* Remove `Runtime.IsStarted`
* Deprecated `.GetLatestPackageVersionAsync`

## 3.0.1

### Added

* Nothing!

### Improvements

* Typings have been improved to contain an additional argument for network controllers
* Signals now use a wrapper

### Removed

* Nothing!

## 3.0.0

### Added

* Add `CanaryEngine.RuntimeCreatedSignals`
* Add `CanaryEngine.RuntimeCreatedNetworkControllers`
* Support for invoking server
* Reworked data saving
* Add `CanaryEngineClient.PlayerBackpack`
* Add `Replicated` folder to `CanaryEngine/Media`
* Proper documentation to almost all methods, expect finished docs to come along when **v3.1.0** releases with a few hotfixes and general improvements
* Add `CanaryEngineServer.Media.Server`
* Add `CanaryEngineClient.Media.Client`
* Add `Spring` to default packages
* Add `Promise` to default packages
* Add `MatchmakingService`

### Improvements

* Turn `NetworkSignal` into `NetworkController`
* Add `signalName` parameter to `CanaryEngine.CreateSignal` for easier signal access across scripts (breaking change)
* Add error when trying to import packages during runtime
* Fix `Runtime.IsStarted` not working
* Move `Utility`, `Benchmark`, and `Statistics` to their own each modules for better loading times
* Improve engine context fetch code
* CustomScriptSignal is now ScriptSignal, old ScriptSignal is now BasicScriptSignal
* Improve BridgeNet wrapper to be more clean + efficient
* Internal tooling is extremely easier to access

### Removed

* Remove `CanaryEngineServer.GetDataService`
* Remove `CanaryEngineServer.Media`
* Remove `CanaryEngineClient.Media`

## 2.2.1

### Added

* Add Once + Disconnect to `NetworkSignals`

### Improvements

* Fix bugs
* Clean Code
* Framework starts earlier for better server security

### Removed

* Nothing!

## 2.2.0

### Added

* Add 'Statistics Library'
* Add support for EasyDocs
* Add `PlayerGui` to `EngineClient`.

### Improvements

* Fix bugs
* Clean Code

### Removed

* Nothing!

## 2.1.0

### Added

* Add Vendor folder under new packages

### Improvements

* Make it so that return data from regular `Signal`s return in a table instead of a tuple for consistency
* Create wrapper for BridgeNet instead of editing the source code
* Improve code
* Remove BridgeNet output logs
* Fix support for Wait
* Update `base64` by @Gooncreeper

### Removed

* Nothing!

## 2.0.0

### Added

* Added option to install default packages in the plugin
* Added new `Utility` functions to the module
* Add `base64` by @Gooncreeper
* Add `EngineServer.GetDataService()`
* Add support for debugging in live games

### Improvements
* Clean up code
* Bug fixes
* Fix up `random_gen`

### Removed

* Remove `EngineClient.LocalObjects`
* Remove `EngineClient.PreinstalledPackages`
* Remove `EngineServer.PreinstalledPackages`

## 1.2.0

### Added

* Added install and uninstall to plugin
* Added `Utility`, `Benchmark`, and `Serialize` (BlueSerializer by @commitblue) libs to the main module
* Add support for checking framework version automatically with `GetLatestPackageVersionAsync`, it is now an attribute under the main module.
* Better `NetworkSignal` typing

### Improvements

* A few QOL fixes
* Bug fixes

### Removed

* Removed intellisense from plugin, it's sadly impossible

## 1.1.0

* Public release! 🥳