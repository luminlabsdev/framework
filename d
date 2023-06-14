a## About

Now, you may be asking, what even is CanaryEngine? Well, CanaryEngine is a framework that is lightweight and doesn't require almost any set up at all. It was designed to be easily backwards compatible with your game. It has a great networking system, known as @ffrostfall's [BridgeNet2](https://devforum.roblox.com/t/bridgenet2-v010-alpha-a-multi-paradigm-blazingly-fast-highly-equipped-networking-library-for-roblox/2189165), which handles all networking in your game. BridgeNet was designed to be super fast and lightweight too, and comparing roblox's remotes with BridgeNet, there seems to be a drastic difference. It also comes with @maddjames28's [DataService](https://devforum.roblox.com/t/dataservice-a-profile-manager-for-profileservice/2174090), which is a module that handles data in your game with an object-oriented approach while using @loleris' [ProfileService](https://devforum.roblox.com/t/save-your-player-data-with-profileservice-datastore-module/667805). The main reason I created CanaryEngine was because most frameworks out there were too complex, and the ones that weren't complex were written terribly. I can say that Knit or any other of the well-known frameworks are better than this, but I personally I like to design my own systems that fit my liking. Knit is just too feature packed and heavy (in my opinion). CanaryEngine lets you do your own thing. The only stuff that CanaryEngine is supposed to do is organize your game and help you keep track of it, along with simplifying and enhancing data saving and networking.

## Why you should (maybe?) use it

I won't go out and say that this is the best framework or anything, but here are a few reasons why you might want to use it.

* **Type Safe** - Fully compatible with Roblox's intellisense.

* **Simple API** - There is very little API to interact with, therefore it shouldn't take long to get used it!

* **Fully Documented** - All functions in the main module are fully documented, along with the types (documentation site coming soon!)

* **Easy Setup** - Simply require the module on the server, and your game will be set up automatically.

* **Nicely Organized** - Their are folders such as Scripts, Packages, and Media each with their own client, server, and shared (later referred to as global) folders.

* **Lightweight** - The framework is really lightweight, with only about 4 modules needed to startup and function, totaling to ~400 lines of code (including function documentation).

## Is it better than Knit?

No. It is definitely not better than Knit, but for people like me that like to do their programming in studio it may be. Knit will most likely always be the superior of all frameworks, so saying this is better than Knit is probably very controversial.

## Alright, sounds good, how do I set it up?

Setting up should only take you about 3 minutes. To set up, place the RBXM or model into `ReplicatedStorage`. From there, you can press test, and the default scripts should print `Hello, client!` and `Hello, server!`. You should also get a `Framework has successfully loaded!` message as well. After this, you can keep adding scripts, packages, and media that can be accessed through `CanaryEngine.GetEngineServer/Client().Media, .Packages, etc.` A more advanced tutorial will be on the main site once it is finished. To create packages/scripts, you can simply copy over stuff from `CanaryEngine.Templates`.
