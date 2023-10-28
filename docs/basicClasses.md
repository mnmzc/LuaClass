---
sidebar_position: 2
---

# Basic Classes
Generally, it is a good practice to only have one class per file. You would create the class and then return it out of your ModuleScript. This helps you reuse classes in different scripts without defining it in each script.

Your files will generally want to have this structure.
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Class = require(ReplicatedStorage.Packages.Class)

local MyClass = Class.new(function(def)
    -- Define the class here...
)

return MyClass
```
:::note
It is crucial that you include the `def` parameter in your defining function. You need it to define your class.
:::

Now, we can create objects of that class in any other file.
```lua
local MyClass = require(Path.To.Class)
local myObject = MyClass.new()
```