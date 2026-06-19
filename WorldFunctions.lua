-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local player = Players.LocalPlayer
local ClientScript = player.PlayerScripts:WaitForChild("ClientScript")
local env = getsenv(ClientScript)
local IDInfo = require(ReplicatedStorage:WaitForChild("IDInfo"))

-- Constants
local B_SIZE = 3

-- World Functions
function getBlock(x, y, z)
    if not env.getBlock then return nil end
    return env.getBlock(x, y, z)
end

function getBlockID(x, y, z)
    local block = getBlock(x, y, z)
    if block == nil then return nil end
    if type(block) == "number" then return block end
    if type(block) == "table" then return block.id end
    return nil
end

function getChunk(chunkX, chunkZ)
    if not env.getChunk then return nil end
    return env.getChunk(chunkX, chunkZ)
end

--[[
function getNearbyEntities(pos, dimension)
    if not env.getNearbyEntities then return {} end
    return env.getNearbyEntities(pos, dimension or "overworld")
end
]]

function convertBlockIdToBlockName(blockId)
    if type(blockId) ~= "number" then return nil end
    local info = IDInfo[blockId]
    if not info then return nil end
    if info.block ~= true then return nil end
    return info.name
end

function WorldToBlock(pos)
    if typeof(pos) ~= "Vector3" then return nil end
    return 
        math.floor(pos.X / B_SIZE + 0.5),
        math.floor(pos.Y / B_SIZE + 0.5),
        math.floor(pos.Z / B_SIZE + 0.5)
end

function BlockToChunk(bx, bz)
    return math.floor(bx / 16), math.floor(bz / 16)
end

function getBlockProperties(x, y, z)
    local block = getBlock(x, y, z)
    if type(block) == "table" and block.Properties then
        return block.Properties
    end
    return nil
end

return {
    getBlock = getBlock,
    getBlockID = getBlockID,
    getChunk = getChunk,
--  getNearbyEntities = getNearbyEntities,
    getBlockProperties = getBlockProperties,
    convertBlockIdToBlockName = convertBlockIdToBlockName,
    WorldToBlock = WorldToBlock,
    BlockToChunk = BlockToChunk
}
