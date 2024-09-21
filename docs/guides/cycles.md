# Cycles

Cycles are essentially lifecycle events like in any other framework. They allow for code to constantly run in the background without interupting anything that is in the main thread. Notable mentions include `PlayerAdded` and `PostSimulation`. The purpose of cycles is so that we can introduce more safety while using the framework and run into less issues like race conditions or unexplainable errors. New cycles cannot be created after `.Start` is finished.

## Usage

Usage of cycles is very minimal and simple. Here's how to use one:

```luau
local Frames = 0
Lumin.Cycle("PostSimulation", function(deltaTime)
    print(deltaTime)
    print("Frame number", Frames += 1)
end)
```

The code above will print the amount of frames that have passed since the server started or the client joined entered the data model. It will also print the delta time for each frame.

## Cycle Types

This is a list of all of the allowed cycle types. It can be seen below.

- `PostSimulation`<br>
Fires every *frame* after the physics simulation has completed.

- `PreAnimation`<br>
Fires every *frame* prior to the physics simulation but after rendering.

- `PreRender`<br>
Fires every *frame* prior to the frame being rendered. **(Client only)**

- `PreSimulation`<br>
Fires every *frame* prior to the physics simulation.

- `PlayerAdded`<br>
Fires after a player is added/joins.

- `PlayerRemoving`<br>
Fires before a player is removed/leaves.
