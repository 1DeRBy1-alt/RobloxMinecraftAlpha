if getgenv().scaffoldLoaded == true then return end
getgenv().scaffoldLoaded = true

-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local SendState = ReplicatedStorage:WaitForChild("SendState")
local ClientScript = player.PlayerScripts:WaitForChild("ClientScript")
local env = getsenv(ClientScript)

local module = getgenv().ModuleManager.new("Scaffold", {
    delay = 0.05,
})

-- World Functions --
local WorldFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/refs/heads/main/WorldFunctions.lua"))()
local getBlockID = WorldFunctions.getBlockID
local WorldToBlock = WorldFunctions.WorldToBlock
local convertBlockIdToBlockName = WorldFunctions.convertBlockIdToBlockName
local getChunk = WorldFunctions.getChunk

local lastPlace = 0
local entityRef = nil

local LocalEntity = require(ReplicatedStorage:WaitForChild("LocalEntity"))

local oldLocalEntity
oldLocalEntity = hookfunction(LocalEntity, function(state, env, dt)
    if state and state.Pos and state.Motion then
        entityRef = state
    end
    return oldLocalEntity(state, env, dt)
end)

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    entityRef = nil
end)

-- Functions --
local function isEntityValid(ent)
    if not ent or not ent.Pos or not ent.Motion then return false end
    local posX, posY = ent.Pos.X, ent.Pos.Y
    return posX == posX and posY == posY
end

local function predictMotionY(entity, steps)
    if not isEntityValid(entity) then return nil end

    local simMotionY = entity.Motion.Y
    local simPosY = entity.Pos.Y
    local isFlying = entity.Fly or false
    local onGround = entity.OnGround

    if isFlying then
        local results = {}
        for i = 1, steps do
            results[i] = { posY = simPosY, motionY = simMotionY, worldY = simPosY * 3 }
        end
        return results
    end

    local results = {}
    for i = 1, steps do
        simMotionY = (simMotionY - 0.08) * 0.98
        simPosY = simPosY + simMotionY

        if onGround and simMotionY < 0 then
            simMotionY = 0
        end

        results[i] = { posY = simPosY, motionY = simMotionY, worldY = simPosY * 3 }
    end

    return results
end

local function getHeldItemID()
    local slot = getrenv()._G.SlotSelected
    if slot and type(slot) == "table" and slot.id and slot.id > 0 then
        if convertBlockIdToBlockName(slot.id) then
            return slot.id
        end
    end
    return nil
end

local function getPlacePos()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if isEntityValid(entityRef) then
        local posX, posY, posZ = entityRef.Pos.X, entityRef.Pos.Y, entityRef.Pos.Z
        local blockX = math.floor(posX)
        local blockZ = math.floor(posZ)

        local targetY
        if entityRef.OnGround then
            targetY = math.floor(posY) - 1
        else
            local predictions = predictMotionY(entityRef, 1)
            if predictions then
                local futureY = predictions[1].posY
                local motionY = predictions[1].motionY
                local predictionRatio = math.max(0.3, math.min(1.0, math.abs(motionY) * 2))
                targetY = math.floor(posY + (futureY - posY) * predictionRatio) - 1
            else
                targetY = math.floor(posY) - 1
            end
        end

        local id = getBlockID(blockX, targetY, blockZ)
        if id == 0 or not id then
            return Vector3.new(blockX, targetY, blockZ), Vector3.new(0, 0, 0)
        end
    else
        local posY = hrp.Position.Y
        local fracY = (posY / 3) % 1
        local targetY = math.floor(posY / 3) + (fracY > 0.3 and -1 or -2)

        local x, _, z = WorldToBlock(hrp.Position)
        local id = getBlockID(x, targetY, z)
        if id == 0 or not id then
            return Vector3.new(x, targetY, z), Vector3.new(0, 0, 0)
        end
    end
end

if not getgenv().scaffoldHooked then
    getgenv().scaffoldHooked = true

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() and (method == "InvokeServer" or method == "invokeServer") and self == SendState then
            local data = args[1]

            if type(data) == "table" then
                if (data.ibreak or data.ibroken or data.ieaten or data.iuse or data.iinteract or data.icraft) then
                    return oldNamecall(self, ...)
                end

                if module.enabled then
                    local now = tick()

                    if now - lastPlace >= (module:get("delay") or 0.05) then
                        local blockId = getHeldItemID()

                        if blockId then
                            local pos, nor = getPlacePos()

                            if pos then
                                data.iplace = true
                                data.targetBlock = pos
                                data.targetBlockNor = nor
                                lastPlace = now

                                local cX = math.floor(pos.X / 16)
                                local cZ = math.floor(pos.Z / 16)
                                local chunk = getChunk(cX, cZ)

                                if chunk then
                                    chunk:Set(pos.X % 16, pos.Y, pos.Z % 16, {id = blockId}, true)
                                end
                            end
                        end
                    end
                end

                return self.InvokeServer(self, data)
            end
        end

        return oldNamecall(self, ...)
    end)
end
