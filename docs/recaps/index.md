# Recap - April 2024
April 28, 2024 · 1 min read

by **[James - Lead Programmer](https://github.com/2jammers)**

---

**Hi developers,**

With update 8.0.0, you recieve a totally refreshed and rethought framework

### Custom Networking System

Instead of relying on an external package, we have made our own custom networking system with similar performance gains. Some improvements include the addition of the `FireNow` API. This allows you to skip batching and not fire the next frame, and we also introduced batching for unreliable events. If the collected data is under 840 bytes by the time it is batched, you will see performance gains.

### Better Module Loading

We improved the module loader API, now allowing for a filter and a parent instance instead of a list. We highly encourage a single-script architecture in light of this change, and this makes it much easier.

### Better Documentation

We have rewritten the tutorials in the documentation to include better wording and they are now much easier to follow along with. We also introduced more tutorials for each API area.

### Branding Changes

We changed the framework name from CanaryEngine to LuminFramework in light of the organization changing. We hope that it is much easier to distinguish the framework from a game engine now!

---

If you're interested in contributing, please make a PR on our GitHub!