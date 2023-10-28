---
sidebar_position: 3
---

# Defining the Class
## Defining Properties
Defining properties is very simple. Just assign the property to a new index of the `def` keyword like you would any other table.
```
def.prop1 = "hi"
def.prop2 = "bye"
```

## Defining Methods
A class would be useless without methods. If you had a "class" with just properties, you would only need to use a table. However, you can easily define a method making use of the `Class.addMethod` function. This will return an object. Finally, assign the method to the `def` keyword, using the name of the method as the index.

```lua
def.myMethod = Class.addMethod(function(self, arg1, arg2)
    self.prop1 = arg1
    self.prop2 = arg2
end)
```

### Constructor
A constructor method is also defined in the definition of a Class. To do this, you must specifically set the `_construct` key of the `def`. Like other methods, make sure to use `Class.addMethod`. Now, when you instantiate an object using `MyClass.new()` it will pass the parameters to your construction function.

### Method Modifiers
Method modifiers are useful for specifying how your method can be accessed. To get access 

#### static
- The **static** modifier specifies that a method can be used without instantiating an object. You would do this by directly calling the method on a *class*. (It would still work if you called it on an object.)  

```lua
local static, private = Class.modifiers()
local Math = Class.new(function(def)
    def.add = Class.addMethod(static, function(num1, num2)
        return num1 + num2
    )
)

-- The below statement will work fine because 'add' is a static method, we can call it without instantiating an object of the 'Math' class.
print(Math.add(7, 3)) -- 10
```

- The **private** modifier specifies that a method can only be used internally in a definition. This means that if you want to call a private method, use the `def` and then call the method.

```lua
local static, private = Class.modifiers()
local Cake = Class.new(function(def)
    def.temp = 250

    def.getTemperature = Class.addMethod(private, function(self, num1, num2)
        return self.temp
    )

    def.isCooked = Class.addMethod(function(self)
        local temp = def.getTemperature()

        if (temp >= 250) then
            print("Cooked!")
        else
            print("Not yet")
        end
    end)
)

local myCake = Cake.new()
myCake.isCooked() -- Cooked!

myCake.getTemperature() -- Throws an error since 'getTemperature' is private
```