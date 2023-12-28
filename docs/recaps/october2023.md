# Engine Recap - October 2023
October 27, 2023 · 1 min read

by **[James - Lead Programmer](https://github.com/lolmansReturn)**

---

**Hi developers,**

With engine update 4.0.0 and 5.0.0, the entire framework has been revamped! We've been looking closely at how Canary is integrated in your projects and took after that.

### New Internals

The internals of the framework have been rewritten almost completely, and was also optimized a lot. There is now a large increase of speed when starting up and creating new objects.

### Plugin QOL Features

We've worked on adding lots of QOL features to the plugin and our APIs especially, some of these include the new `LogEvent` API which logs events in studio. We're trying to optimize this so it doesn't impact your production code as much!

### Switched to Red

We have switched to Red's networking system and revamped the Network Controller API once again, making it even more accurate and easy to use than before.

### General Structure Redesign

Ever since the beginning of the framework, structuring has been a large problem. After 3 iterations from the start, we're proud to say that the new one is final. This renames various folders like Replicated to Shared and Media to Assets.

### Upgraded Libraries

To come with this, we have also upgraded our libraries. Some newly introduced ones include Snacky and UIShelf, and we plan on deprecating other libraries as we advance into the future.

---

If you're interested in contributing, please make a PR on our GitHub! We worked hard on this update so please give your thanks.