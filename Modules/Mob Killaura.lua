-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --
local player = Players.LocalPlayer
local lastHit = 0
local MAX_RANGE = 16
local mobCache = {}

local module = getgenv().ModuleManager.new("MobKillaura", {
    delay = 0.05,
})

-- World Functions --
local WorldFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/main/WorldFunctions.lua"))()
local WorldToBlock = WorldFunctions.WorldToBlock

-- Functions --
local function getClosestMob(playerPos)
    local closest = nil
    local shortest = MAX_RANGE
    local px, py, pz = WorldToBlock(playerPos)

    for uuid, mob in pairs(mobCache) do
        if tick() - mob.t < 5 and (not mob.h or mob.h > 0) then
            local mx, my, mz = mob.c.X, mob.c.Y, mob.c.Z
            local dist = math.sqrt((mx - px)^2 + (mz - pz)^2)
            if dist <= shortest then
                shortest = dist
                closest = uuid
            end
        else
            mobCache[uuid] = nil
        end
    end
    return closest
end

ReplicatedStorage.UpdateWorld.OnClientEvent:Connect(function(data)
    if data and data.chunks then
        for _, chunk in pairs(data.chunks) do
            if chunk[3] and chunk[3].entitydata then
                for _, e in pairs(chunk[3].entitydata) do
                    if e.UUID and e.id ~= "player" and e.id ~= "item" then
                        local cx, cy, cz = WorldToBlock(e.Pos)
                        mobCache[tostring(e.UUID)] = {c = Vector3.new(cx, cy, cz), h = e.Health, t = tick()}
                    end
                end
            end
        end
    end
end)

if not getgenv().mobKaHooked then
    getgenv().mobKaHooked = true
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() and module.enabled and (method == "InvokeServer" or method == "invokeServer") and self.Name == "SendState" then
            local data = args[1]
            if type(data) == "table" then
                local currentTime = tick()
                local delayTime = module:get("delay") or 0.05

                if (data.ibreak or data.ibroken or data.iplace or data.iinteract or data.ieat or data.ieaten or data.iuse or data.icraft or data.targetEntity) then
                    return oldNamecall(self, ...)
                end

                if (currentTime - lastHit) >= delayTime then
                    local closestUUID = getClosestMob(data.pos)
                    if closestUUID and not data.targetEntity then
                        data.targetEntity = closestUUID
                        data.iattack = true
                        lastHit = currentTime
                    end
                end

                return self.InvokeServer(self, data)
            end
        end

        return oldNamecall(self, ...)
    end)
end
