-- ClassBuilder Utility Functions

local Utils = {}

function Utils.FindTableValue(t: table, Value: any): (any | nil, number | nil)
    for index, item in pairs(t) do
        if item == Value then
            return item, index
        end
    end
end

return Utils