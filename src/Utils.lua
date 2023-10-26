-- ClassBuilder Utility Functions

--[=[
    @class Utils

    A base class for various utility functions. Due to the nature of this project, this class won't contain many methods.
]=]
local Utils = {}

--[=[
    @param t table -- The table that will be searched
    @param Value any -- The value to look for
    @return any -- The value that is found, if any
    @return number -- The position of this value in table

    Searches for a value in a table. If found, returns the value followed by the index. If the value is not present, `nil` is returned.

    ```lua
    local myTable = {5, 8, 30}
    local value, index = Utils.FindTableValue(8)

    print(value, index) -- 8, 2
    ```
]=]
function Utils.FindTableValue(t: table, Value: any): (any | nil, number | nil)
    for index, item in pairs(t) do
        if item == Value then
            return item, index
        end
    end
end

return Utils