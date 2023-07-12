---
sidebar-position: 4
---

# Package System

One of Canary's greatest strengths is the built in package system, which allows for many more oppurtunities. As of v3.2.0, intellisense is now a supported feature natively for packages! This also allows you to get an easy reference to all of your packages because they are now stored in an exclusive list.

### Inserting Packages

To insert a new package, simply use the 'Create New Instance' function of the plugin, then from there you can insert a new package, for either the client, to be replicated, or the server. From there, you can reference the module in your script and start using it! Here's an example of how you would grab a package from the server.

### Inserting Scripts

Inserting new scripts is also a very straightforward process and very similar to packages. First, create a new instance, then select either client script or server script from the dropdown menu. In order to reference a server-sided package, you must create a server script. Here's an example of how you would get your package from the script we just created:

```lua
local Packages = CanaryEngineServer.Packages.Server
local MyPackage = Packages.MyPackage

MyPackage.MyFunction()
```

### Package Vendor

You may notice that when you create a new package it has a child named 'Vendor'. In a lot of languages, a vendor is an easy way to prevent recursiveness, and that's what we are doing here. The vendor folder should automatically be referenced in your new package, from there you can insert dependencies of your package inside of vendor, and then import them inside the package. Another benefit to using a vendor folder is a less messy file structure, as packages just referencing others back and forth can start to be a huge problem for anyones codebase.