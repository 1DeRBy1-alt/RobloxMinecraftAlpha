if getgenv().ChestStealerLoaded then return end
getgenv().ChestStealerLoaded = true

local rs = game:GetService("ReplicatedStorage")
local idinfo = require(rs:WaitForChild("IDInfo"))
local clientScript = game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("ClientScript")
local env = getsenv(clientScript)

local module = getgenv().ModuleManager.new("ChestStealer", {
    delay = 0.5,
})

local function getInv(func)
    for _, v in pairs(debug.getupvalues(func)) do
        if type(v) == "table" then
            for _, item in pairs(v) do
                if type(item) == "table" and type(item.Get) == "function" and item.Slot ~= nil then
                    return v
                end
            end
        end
    end
    return nil
end

local function getDefaultOpen()
    for _, v in pairs(debug.getupvalues(env.renderInventory)) do
        if type(v) == "string" and (v == "chest" or v == "furnace" or v == "default" or v == "crafting") then
            return v
        end
    end
    return ""
end

local function getSlotObj(inv, slotNum)
    if not inv then return nil end
    for _, v in pairs(inv) do
        if v:Get("Slot") == slotNum then
            return v
        end
    end
    return nil
end

local function isValidTargetSlot(slotNum)
    return type(slotNum) == "number" and slotNum >= 0 and slotNum <= 35
end

local isStealing = false

task.spawn(function()
    while task.wait(module:get("delay") or 0.5) do
        if not module.enabled then continue end
        if isStealing then continue end

        local defaultOpen = getDefaultOpen()
        if defaultOpen ~= "chest" and defaultOpen ~= "furnace" then continue end

        isStealing = true

        local pInv = getInv(env.updateResultSlot)
        local cInv = getInv(env.updateExternal)

        if type(pInv) == "table" and type(cInv) == "table" then
            local function getEmptyPlayerSlot()
                for i = 9, 35 do
                    if not getSlotObj(pInv, i) then return i end
                end
                for i = 0, 8 do
                    if not getSlotObj(pInv, i) then return i end
                end
                return nil
            end

            local chestItems = {}
            for _, cSlot in pairs(cInv) do
                table.insert(chestItems, cSlot)
            end

            local moved = false
            for _, cSlot in ipairs(chestItems) do
                local cId = cSlot:Get("id")
                if cId and cId ~= 0 then
                    local maxStack = idinfo[cId] and idinfo[cId].Stack or 64

                    for _, pSlot in pairs(pInv) do
                        local cCount = cSlot:Get("Count")
                        if not cCount or cCount <= 0 then break end

                        local pSlotNum = pSlot:Get("Slot")
                        if isValidTargetSlot(pSlotNum) and pSlot:Get("id") == cId then
                            local pCount = pSlot:Get("Count")
                            if pCount < maxStack then
                                local moveAmt = math.min(maxStack - pCount, cCount)
                                cSlot:Move(cInv, pInv, pSlotNum, moveAmt)
                                moved = true
                            end
                        end
                    end

                    while true do
                        local cCount = cSlot:Get("Count")
                        if not cCount or cCount <= 0 then break end

                        local emptySlot = getEmptyPlayerSlot()
                        if not emptySlot then break end

                        local moveAmt = math.min(maxStack, cCount)
                        cSlot:Move(cInv, pInv, emptySlot, moveAmt)
                        moved = true
                    end
                end
            end

            if moved then
                env.renderInventory()
            end
        end

        isStealing = false
    end
end)
