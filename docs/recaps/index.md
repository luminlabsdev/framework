# Engine Recap - December 2023
December 27, 2023 · 1 min read

by **[James - Lead Programmer](https://github.com/lolmansReturn)**

---

**Hi developers,**

With framework update 6.1.0 and 6.2.1, we have been working type validation features and larger bug fixes.

### Type Validation

We are excited to introduce the all new type validation features! These make it even easier to protect the server from unwanted client attacks and mistakes in your own code. This comes with an all new FFlag attached to the init script of the framework. It also allows you to stop adding janky type checking code into your server network controller listeners.

### Unreliable Networking

Unreliable networking is one of the most important features of networking, as it allows packets to be sent through without being checked. This dramatically reduces bandwidth and ping, so it's good for movement systems and other frame-reliant network creations.

### Large Unnoticed Issues

There were a lot of issues internally that weren't ever noticed. The main issue here was that `PlayerGui` or `Backpack` properties were not updating upon a new character spawning. This has caused a lot of issues and we are glad the pin point has finally been found.

### Deprecate Older Technology

We have deprecated older `Debugger` functions which were mainly used before `LogEvent`. `LogEvent` is the all-in-one solution to debugging your scripts and not cluttering public outputs.

---

If you're interested in contributing, please make a PR on our GitHub!