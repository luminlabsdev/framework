# Changelog

## v3.0.0

**Added**

**Improvements**

* Turn `NetworkSignal` into `NetworkController`

**Removed**

## v2.2.1

**Added**

* Add Once + Disconnect to `NetworkSignals`

**Improvements**

* Fix bugs
* Clean Code
* Framework starts earlier for better server security

**Removed**

* Nothing!

## v2.2.0

**Added**

* Add 'Statistics Library'
* Add support for EasyDocs
* Add `PlayerGui` to `EngineClient`.

**Improvements**

* Fix bugs
* Clean Code

**Removed**

* Nothing!

## v2.1.0

**Added**

* Add Vendor folder under new packages

**Improvements**

* Make it so that return data from regular `Signal`s return in a table instead of a tuple for consistency
* Create wrapper for BridgeNet instead of editing the source code
* Improve code
* Remove BridgeNet output logs
* Fix support for Wait
* Update `base64` by @Gooncreeper

**Removed**

* Nothing!

## v2.0.0

**Added**

* Added option to install default packages in the plugin
* Added new `Utility` functions to the module
* Add `base64` by @Gooncreeper
* Add `EngineServer.GetDataService()`
* Add support for debugging in live games

**Improvements**
* Clean up code
* Bug fixes
* Fix up `random_gen

**Removed**

* Remove `EngineClient.LocalObjects`
* Remove `EngineClient.PreinstalledPackages`
* Remove `EngineServer.PreinstalledPackages``

## v1.2.0

**Added**

* Added install and uninstall to plugin
* Added `Utility`, `Benchmark`, and `Serialize` (BlueSerializer by @commitblue) libs to the main module
* Add support for checking framework version automatically with `GetLatestPackageVersionAsync`, it is now an attribute under the main module.
* Better `NetworkSignal` typing

**Improvements**

* A few QOL fixes
* Bug fixes

**Removed**

* Removed intellisense from plugin, it's sadly impossible