# Statistics

Gives statistics based on data sets.

## Functions

### GetMedian

Gets the number that is in the middle of the dataset, more info can be found [here](https://en.wikipedia.org/wiki/Median). Here's an example scenario:

```lua
local CollectedData = {6, 8, 3, 7, 9, 0, 4, 1}

print(Statistics.GetMedian(CollectedData))
-- Output: 8
```

**Parameters**

* **numberList:** `Array<number>`\
The dataset to perform the action on

**Returns**

* **number**

---

### GetMean

Gets the most common number in the dataset, more info can be found [here](https://en.wikipedia.org/wiki/Mean). Here's an example scenario:

```lua
local CoinsForPlayers = {651, 8801, 371, 79, 918, 0, 46, 183}

print(Statistics.GetMean(CoinsForPlayers)) -- Get the average amount of coins each player has, keep in mind 8801 will skew the data.
-- Output: 1381.125
```

**Parameters**

* **numberList:** `Array<number>`\
The dataset to perform the action on

**Returns**

* **number**

---

### GetMode

Gets the number that occurs most in the provided dataset, nil if none or each number occurs the same amount of times. More info can be found [here](https://en.wikipedia.org/wiki/Mode_(statistics))

**Parameters**

* **numberList:** `Array<number>`\
The dataset to perform the action on

**Returns**

* **number?**