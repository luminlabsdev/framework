# Benchmark

The benchmark library is an easy way to benchmark any of your code, while giving useful stats like the average time, and the run that took the most amount of time.

### Benchmarking a Function

Benchmarking a function is quite easy, and takes less time than the traditional ways while also bringing more features to the table. Here is a simple example of a function switching variable values each time it is run;

```lua
local a, b = 0, 1

local MyBenchmark = Benchmark.CreateBenchmark()
local BenchmarkResult = MyBenchmark:SetFunction(500, function()
	a, b = b, a
end)

print(BenchmarkResult) -- Output: Shortest: 0.0018000009731622413ms Total: 0.04350000017439015ms Average: 0.02211200087549514ms Longest: 0.039200000173877925ms
```
Keep in mind that the above actually returns a table, that when tostring is used on it, it will turn into a neat form as above.