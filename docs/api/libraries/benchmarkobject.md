# BenchmarkObject

Allows you to measure function times.

## Properties

### EndTime

The time (in seconds) the benchmark was ended at.

* **number**

---

### StartTime

The time (in seconds) the benchmark was started at.

* **number**

---

### IsCompleted

A boolean to decide if the benchmark should be GC'ed.

* **boolean**

## Methods

### Start

Starts the benchmark object.

#### Returns

* **void**

---

### Stop

Stops the benchmark from running and destroys it, returns the amount of time it took to complete the code above it.

#### Returns

* **number**

---

### GetCurrentTime

Gets the current elapsed time of the benchmark, this will error if the benchmark is inactive.

#### Returns

* **number?**

---

### SetFunction

Sets the function to be ran `timesToRun` amount of times.

:::danger
[BenchmarkObject:Stop](#stop) is already called after this function is finished, calling the latter manually will result in an error.
:::


#### Parameters

* **timesToRun:** `number`\
The amount of times to run `func`.

* **func:** `(timesRan: number) -> ()`\
The function to run for each `timesToRun` index, has a `timesRan` argument which is how many times the benchmark has run so far.

#### Returns

* **[BenchmarkData](/api/libraries/benchmark#benchmarkdata)**

---

### Destroy

Destroys the `BenchmarkObject`, this is done automatically after `SetFunction` is finished or `Stop` is called.

#### Returns

* **void**

## Events

### Destroying

A signal that fires when the benchmark has been disposed of.