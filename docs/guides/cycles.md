# Cycles

Cycles are essentially lifecycle events like in any other framework. They allow for code to constantly run in the background without interupting anything that is in the main thread.

## Usage

Usage of cycles is very minimal and simple. Here's how to use one:

### Module 1
```luau
local Cycle = Lumin.Cycle("MyCycle")
Cycle:Fire("Hello!!!")
```

### Module 2
```luau
local function MyCycle(printer: string)
    print(printer) -- Output: Hello!!!
end
```

The output of this should be "Hello!!!"
