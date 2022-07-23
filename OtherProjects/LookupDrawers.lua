local component = require("component")
local sides = require("sides")
local inventory = component.inventory_controller
local redstone = component.redstone
local front = sides.front

function isDrawerFull()
    if redstone.getInput(front) == 15 then
        return true
    end
    return false
    -- local drawerMetadata = inventory.getStackInSlot(sides.front, 2)
    -- if drawerMetadata ~= nil then
        
    -- end
    --local getCurrentItemCount = inventory.getSlotStackSize(sides.front, 2)
end

function getDrawerData()
    local drawerMetadata = inventory.getStackInSlot(sides.front, 2)
    local itemName = nil
    local quantity = nil

    if drawerMetadata ~= nil then
        itemName = drawerMetadata["label"]
        quantity = drawerMetadata["maxSize"]
    end 

    return itemName, quantity
end