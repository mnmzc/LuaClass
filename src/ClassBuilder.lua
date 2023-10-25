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

ClassBuilder.addMethod = function(...)
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

ClassBuilder.new = function(definition)
    local template = {
        def = {},
        methods = {},
        properties = {}
    }

    local defMt = {}
    defMt.__newindex = function(self, key, value)
        for _, value in pairs(RESTRICTED_DEFINITIONS) do
            if key == value then
                error("[ClassBuilder] Attempt to make a class definition using a restricted keyword '" .. key .. "'.")
                return
            end
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

    function template.new()
        local object = table.clone(constructable)
        return constructable
    end

    table.freeze(template)
    
    return template
end
    
ClassBuilder.modifiers = function()
    return static, private
end

return ClassBuilder