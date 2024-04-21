# Changelog

This is the changelog which is changed every update, and we follow semver.

## 7.0.3

---

### Added

* Nothing

### Improvements

* Changed project name from **CanaryEngine** to **LuminFramework**

### Removed

* Nothing

## 7.0.2

---

### Added

* Nothing

### Improvements

* Fix client once again

### Removed

* Frozen client tables; causing issues

## 7.0.1

---

### Added

* Nothing

### Improvements

* If something is not a module when using `ImportPackages`, it will be ignored
* Fixes `Framework.Client` issues with frozen tables

### Removed

* Nothing

## 7.0.0

---

### Added

* Newly upgraded networking library, with `ContextInterface.Network` API
* Renames older API to fit with new standards

### Improvements

* Improves how the network library works with unreliables
* Improves general code
* Fixes bugs within `Canary.Client` **(@DrasticBlink)**
* Changes `Canary.GetFramework` to the just the currently running context

### Removed

* `LuminFramework.CreateAnonymousSignal`
* `ContextInterface.NetworkController`
* `LuminFramework.GetFrameworkShared`
* `LuminFramework.Future`

## 6.2.1

---

### Added

* Networking type validation

### Improvements

* Fixes player gui/backpack properties not updating when player respawns
* Deprecate `Debugger.Debug` and `Debugger.DebugPrefix` functions in favor `Debugger.LogEvent`
* Change prefixes of settings to `FFlag`

### Removed

* Nothing

## 6.1.1

---

### Added

* Nothing

### Improvements

* Improves load time to use milliseconds
* Mainly improves docs
* Cleans up code in a few areas
* Changes how network controller logs are formatted

### Removed

* Nothing

## 6.1.0

---

### Added

* Support for reliable/unreliable network controllers

### Improvements

* Creating an anonymous signal will no longer log the name as 'nil'
* Network controller names now use identifiers
* Network controller creation now displays reliability type in log
* Adds ability to set a listener on a network controller after being initially set

### Removed

* Nothing

## 6.0.0

---

### Added

* Better calculation of startup

### Improvements

* Improved internally logged events to be more clear

### Removed

* `source` param from LogEvent to make code more neat

## 6.0.0-rc1

---

### Added

* Revamped documentation layouts
* Use `.luaurc` file instead of `--!strict`
* Correctly logs when an object is created

### Improvements

* General code improvements and bug fixes
* Improved API naming to be more clear
* Improves `LogEvent` performance
* Update internal naming scheme to reflect frontend
* `:BindToInvocation` will now give a type warning if at least 1 value is returned
* Improve `:BindToInvocation` to disallow returning nil/nothing
* Add Framework and Server/Client tags to internal logs

### Removed

* Remove deprecated alias `LuminFramework.GetFrameworkReplicated`

## 5.1.0

---

### Added

* Revamped plugin, now only creates scripts

### Improvements

* Refined installation process, makes models available only per release.

### Removed

* Nothing

## 5.0.0

---

### Added

* Wally support / Rojo
* Improved documentation
* Adds `ShowLoggedEvents` setting

### Improvements

* Mainly lots of internal improvements and/or optimizations
* Optimized `Debugger.LogEvent` in most cases
* Improves debugger user API
* Framework debugs server and client start time in MS
* Removes need for plugin, can drag/drop anywhere

### Removed

* A lot of useless/deprecated functions or properties

## 4.0.0

(Includes rc1-3)

---

### Added

* Improved API

### Improvements

* Improves structure and others
* Improves internal code to be a lot faster
* LuminFramework is now a standalone modulescript which can be used from anywhere

### Removed

* Nothing

## 4.0.0-rc3

---

### Added

* Rewrote plugin features
* Add package manager to plugin
* Add ability to add custom packages to manager
* Add `Snacky` to Canary Suite

### Improvements

* Improves internal API, should be significantly faster
* Improves networking / signal APIs, tuples are now allowed
* Improves default structure, changed names of all folders to fit developers' needs
* Improve UIShelf, adds text icons + improved menus

### Removed

* Deprecated functions

## 4.0.0-rc2

### Added

* Adds `Red`, revamped the networking system once again and for the last time
* Adds `NetworkController:FireFilter`
* Adds `LuminFramework.ImportPackagesInOrder`2
* Finish API documentation

### Improvements

* Adds event logs when creating classes
* Creating new scripts / packages will now have the date when created, and your username at top (thanks @BigBubba!)
* Changes structure to be more efficient
* Signals / NetworkControllers allow tuples
* Small bug fixes
* QOL fixes

### Removed

* `BridgeNet`

## 4.0.0-rc1

### Added

* Revamped plugin for last time, easier to navigate / add features
* Adds ability to pull packages from any GitHub repo
* Entirely new documentation provider

### Improvements

* Improves EasyProfile ([#3](https://github.com/canary-development/LuminFramework/pull/3), [koxx12](https://github.com/koxx12-dev))
* Renames `CanaryEngineFramework` instance to `Framework`
* Renames `LuminFramework` module to `Init`
* Small bug fixes
* QOL fixes
* Most yielding functions now make usage of Futures

### Removed

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

* `AnonymousSignals` ([#2](https://github.com/canary-development/LuminFramework/pull/2), [koxx12](https://github.com/koxx12-dev))
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

* Add `LuminFramework.RuntimeCreatedSignals`
* Add `LuminFramework.RuntimeCreatedNetworkControllers`
* Support for invoking server
* Reworked data saving
* Add `CanaryEngineClient.PlayerBackpack`
* Add `Replicated` folder to `LuminFramework/Media`
* Proper documentation to almost all methods, expect finished docs to come along when **v3.1.0** releases with a few hotfixes and general improvements
* Add `CanaryEngineServer.Media.Server`
* Add `CanaryEngineClient.Media.Client`
* Add `Spring` to default packages
* Add `Promise` to default packages
* Add `MatchmakingService`

### Improvements

* Turn `NetworkSignal` into `NetworkController`
* Add `signalName` parameter to `LuminFramework.CreateSignal` for easier signal access across scripts (breaking change)
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