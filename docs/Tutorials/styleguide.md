# Style Guide

In CanaryEngine, scripts and packages use a specific style guide. This is a simple guide to follow, and this guide will allow you to create cleaner and more readable code for future updates and debugging.

### General Style

Most scripts and packages use a similar style, but here is a general guide that **everything** should follow:

* **Variables** All variables should be `PascalCase`.
* **Function Declaration** All functions should be `PascalCase`.
* **Function Arguments** Function arguments should always be `camelCase`, no matter what.
* **Tables** Tables follow the same rules as do variables, though empty ones should be declared as `{ }`.
* **Typings** Since types are an integral part of anyones workflow, types should be neat. All types should be `PascalCase`, and should be declared like this `var: type`.

### Commenting

To avoid messy and unreadable code, make sure to make heavy use of comments. This will allow you to know what your code does at a first glance, which helps out with future updates. In scripts and packages, you should, by default, always declare where functions, variables, and where running code should be placed.

```lua
-- // Variables

local MyVariable = 1

-- // Functions

local function MyFunction()
    print("Added new instance to workspace!")
end

-- // Connections

workspace.ChildAdded:Connect(myFunction)

-- // Actions

print("Hello, world!")
```

You can also create your own custom versions of these comments, just by following the same format and giving them a different name.