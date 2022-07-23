local component = require("component")
local transposer = component.transposer

ItemHandler = {}
ItemHandler.__index = ItemHandler

function ItemHandler:new()
    local obj = {}
    setmetatable(obj, ItemHandler)

    return obj
end

function ItemHandler:bufferedItem(side)
    local storageSize = transposer.getInventorySize(side)
    local items = {}

    if storageSize == nil then
        error("No storage found")
    end

    for i = 1, storageSize do 
        local data = transposer.getStackInSlot(side, i)

        if data ~= nil then
            local label = data["label"]

            if items[label] == nil then
                items[label] = {label = label, slot = {}}
            end
            
            --items[label]["slot"][#items[label]["slot"] + 1] = i
            table.insert(items[label]["slot"], i)
        end
    end
    return items
end

return ItemHandler