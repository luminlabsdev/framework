# Engine Recap - August 2023
August 24, 2023 · 2 min read

by **[James - Lead Programmer](https://github.com/lolmansReturn)**

---

**Hi developers,**

With engine update 3.3.5, we have gathered lots of feedback by our users and fixed bugs related to networking.

### More Debugger Resources

We have added 2 new functions and 1 new feature to the debug API. You can now Assert values, and clear the output / cache lists. Calling debug also adds items to the cache list.

### Create Topbar Icons with UIShelf

The new library UIShelf, you can now create topbar icons that mimic the CoreGui 1:1. We've taken into account every single design aspect that the top bar button has and have been able to replicate it.

### Network Controller Improvements

You can now set a client timeout for network controllers, allowing you to minimize timeout errors. This should fix most of the issues you guys have been having as of late.

### Documentation Improvements

We have improved the documentation site! Coming with 4 new detailed tutorials, more API documentation, and this new blog! We will post engine recaps like this here and they will be exclusive to this website. New API sections have also been added to help organize it.

### Plugin Improvements

We have improved the plugin a little bit (no rebuild yet) and have stopped a few more bugs from popping up. BridgeNet has also been updated to 0.5.4. We are planning lots more for the future, and we will be adding the HintService library soon once it is revamped.

---

If you're interested in contributing, please make a PR on our GitHub!