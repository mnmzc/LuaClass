--[=[
    @class ClassBuilder

    The primary class that contains functions to help you create classes.
]=]
local ClassBuilder = {}
local Utils = require(script.Parent.Utils)

-- Modifiers/Symbols
local static = newproxy()
local private = newproxy()
local methodSymbol = newproxy()

local RESTRICTED_DEFINITIONS = {
    "static",
    "private",
    "methods",
    "modifiers",
    "properties",
    "name",
    "call"
}

--[=[
    @prop RESTRICTED_DEFINITIONS {string}
    @within ClassBuilder

    A list of definitions that you are not allowed to use when defining methods or properties.
]=]
ClassBuilder.RESTRICTED_DEFINITIONS = RESTRICTED_DEFINITIONS

-- Interfaces
--[=[
    @interface ClassMethod
    @within ClassBuilder

    .methodSymbol methodSymbol -- A userdata to indicate that this is a method
    .call function -- The function that will be called when this method is used
    .methodModifiers {static | private} -- If you provide the `static` or `private` modifiers, they will appear here

    An object that represents a method that can be consumed by your class definition.
]=]
type ClassMethod = {
    methodSymbol: methodSymbol,
    call: any,
    methodModifiers: static | private
}

--[=[
    @interface Class
    @within ClassBuilder

    .new function -- A function that can be used to instantiate a new object
    .any [function] -- The **static** methods and properties that exist in the class

    Contains a `new` function to instantiate new objects, as well as any static methods.
    
    :::danger
    Attempting to call a non-static method will result in an error. Specify the `static` modifier to use static methods.
    :::
]=]
type Class = {
    new: Object,
    [any]: any
}

--[=[
    @interface Object
    @within ClassBuilder

    .any [function | any] -- The methods and properties of this Object

    An instance of a class. Methods that affect properties of objects will only affect this object.

    :::danger
    If you passed the `private` modifier then you won't be able to call the method directly via the object. Remove the modifier if you need to use it outside of the definition.
    :::
]=]
type Object = {
    [any]: any
}

--[=[
    @function new
    @within ClassBuilder

    @param definition function -- The function that will be called so you can define the class
    @return Class -- The class object that you have created

    Creates a new class, which you can define with the passed function.

    ```lua
    local MyClass = Class.new(function(def)
        def.maxTemp = 250
        def.windy = false

        def.getMaxTemp = Class.addMethod(function()
            return self.maxTemp
        end)
    end)
    ```

    #### The `def` parameter
    This is a parameter that is passed to your defining function. When you assign a new index to the definition, it will either be a method or property. When assigning a new method (static or not),
    you need to use [ClassBuilder.addMethod](#addMethod) so that you can get a [ClassMethod](#ClassMethod). Then, set the key to the new [ClassMethod](#ClassMethod) that you have just created. Now,
    if you want to assign just a general property, you can just set the index equal to whatever you want the property to be. There is no special way to do it, simply imagine you are assigning a
    value to any table.

    ```lua
    def.myFirstProperty = "hi"
    def.mySecondProp = 12
    def.myCoolTable = {
        "cat",
        "dog",
        "bird"
    }

    def.myMethod = Class.addMethod(function()
        -- imagine there was something important here
    end)
    ```

    :::caution
    When you have a `private` method, make sure to only call it with the `def`.
    :::
]=]
ClassBuilder.new = function(definition): Class
    local template = {
        def = {},
        methods = {},
        properties = {}
    }

    local defMt = {}
    defMt.__newindex = function(_, key, value)
        local flag = Utils.FindTableValue(RESTRICTED_DEFINITIONS, key)

        if flag then
            error("[ClassBuilder] Attempt to make a class definition using a restricted keyword '" .. key .. "'.")
            return
        end

        -- First check to see if we're trying to assign a method
        if type(value) == "table" then
            if value.methodSymbol and value.methodSymbol == methodSymbol then
                template.methods[key] = value
                return
            end
        end

        -- If not, then we're trying to add a property
        template.properties[key] = value
    end

    setmetatable(template.def, defMt)
    definition(template.def)

    -- Add the constructable so we can instantiate objects
    local constructable = {}

    -- Handle methods
    for mName, method in next, template.methods do
        -- Private methods can only be called within the definition
        local p = Utils.FindTableValue(method.modifiers, private)
        local s = Utils.FindTableValue(method.modifiers, static)
        local thisCall = method.call

        constructable[mName] = thisCall
        template[mName] = thisCall

        -- Private methods cannot be used externally
        if p then
            local eFunc = function()
                error(string.format("Attempt to call a private method '%s'.", mName))
            end

            constructable[mName] = eFunc
            template[mName] = eFunc

            rawset(template.def, mName, thisCall)
        end

        -- Non-static methods must be called on an instantiated object
        if not s then
            template[mName] = function()
                error(string.format("Attempt to make a static call to non-static method '%s'.", mName))
            end
        end
    end

    -- Handle properties
    for pName, property in next, template.properties do
        template[pName] = property
        constructable[pName] = property
    end

    function template.new(): Object
        local object = table.clone(constructable)
        return object
    end

    table.freeze(template)
    return template
end

--[=[
    @function addMethod
    @within ClassBuilder

    @param ... any -- Modifiers of the function
    @param f function -- The method to obtain a table for
    @return ClassMethod -- The method that can be added to the class

    Creates a table that can be consumed by your class when you define methods.

    ```lua
    local Cake = Class.new(function(def)
        def.bake = Class.addMethod(function(self, temp)
            print("Baking the cake at " .. temp .. "degrees")

            self.cookTemp = temp
            self.crisp = true
        end)
    end)
    ```
]=]
ClassBuilder.addMethod = function(...): ClassMethod
    local args = {...}
    local methodModifiers = {}
    
    -- Add modifiers where applicable
    methodModifiers = table.clone(args)
    table.remove(methodModifiers, #args)

    return {
        ["methodSymbol"] = methodSymbol,
        ["call"] = args[#args],
        ["modifiers"] = methodModifiers
    }
end

--[=[
    @function modifiers
    @within ClassBuilder

    @return static -- The static modifier
    @return private -- The private modifier

    Returns the modifiers that you can pass to your methods.

    ```lua
    local static, private = Class.modifiers()
    local Cake = Class.new(function(def)
        def.announce = Class.addMethod(static, function(flavor)
            print("Gee I sure could go for a " .. flavor .. " cake right about now")
        end)

        def.getTemperature = Class.addMethod(private, function(self)
            return self.cookTemp
        end)

        def.testTemp = Class.addMethod(function(self)
            local cakeTemp = def.getTemperature()
            
            if cakeTemp > 200 then
                print("Yeah we can definitely eat this now")
            else
                print("It needs to go back into the oven")
            end
        end)
    )
    ```

    The **static** modifier specifies that a method can be used without instantiating an object. You would do this by directly calling the method on a *class*. (It would still work if you called it on an object.)
    
    The **private** modifier specifies that a method can only be used internally in a definition. This means that if you want to call a private method, use the `def` and then call the method.
    
    Using the previous example, we can display this functionality with our `Cake` class.

    ```lua
    Cake.announce("chocolate") -- Gee I sure could go for a chocolate cake right about now
    
    local myCake = Cake.new()
    myCake.testTemp() -- It needs to go back into the oven
    ```
]=]
ClassBuilder.modifiers = function()
    return static, private
end

return ClassBuilder