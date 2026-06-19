if getgenv().xrayLoaded == true then return end
getgenv().xrayLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local ClientScript = player.PlayerScripts:WaitForChild("ClientScript")
local env = getsenv(ClientScript)

local module = getgenv().ModuleManager.new("XRay", {})
local xrayfolder = workspace:FindFirstChild("XrayFolder") or Instance.new("Folder", workspace)
xrayfolder.Name = "XrayFolder"

local WorldFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/main/WorldFunctions.lua"))()
local getBlockID = WorldFunctions.getBlockID
local convertBlockIdToBlockName = WorldFunctions.convertBlockIdToBlockName

local ores = {
    diamond = Color3.fromRGB(35, 207, 219),
    iron    = Color3.fromRGB(110, 105, 105),
    gold    = Color3.fromRGB(245, 242, 71),
    coal    = Color3.fromRGB(56, 59, 56),
}

local oreCache = {}

local visuals = {}
local chunksScanned = {}
local scanning = {}

local ChunksFolder = workspace:WaitForChild("Chunks")

local function makeVisual(color, part)
    local gui = Instance.new("BillboardGui")
    gui.Name = "bulb"
    gui.Parent = part
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(1, 0, 1, 0)

    local frame = Instance.new("Frame")
    frame.Name = "b"
    frame.Parent = gui
    frame.BackgroundColor3 = color
    frame.BorderColor3 = Color3.fromRGB(31, 31, 31)
    frame.BorderSizePixel = 4
    frame.Position = UDim2.new(0.1, 0, 0.1, 0)
    frame.Size = UDim2.new(0.8, 0, 0.8, 0)
end

local function getOreColor(name)
    if not name then return nil end
    if oreCache[name] ~= nil then
        return oreCache[name]
    end
    
    local lower = string.lower(name)
    for oreName, color in pairs(ores) do
        if string.find(lower, oreName) then
            oreCache[name] = color
            return color
        end
    end
    
    local isOre = string.find(lower, "ore") and Color3.new(1, 1, 1) or false
    oreCache[name] = isOre
    return isOre or nil
end

local function addVisual(x, y, z, color, name, chunkName)
    local key = x + (y * 1000000) + (z * 1000)
    if visuals[key] then return end

    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CanTouch = false
    part.CastShadow = false
    part.Transparency = 1
    part.Size = Vector3.new(3, 3, 3)
    part.Position = Vector3.new(x * 3, y * 3, z * 3)
    part.Parent = xrayfolder

    makeVisual(color, part)
    visuals[key] = { Part = part, Chunk = chunkName, X = x, Y = y, Z = z }
end

local function removeVisual(x, y, z)
    local key = x + (y * 1000000) + (z * 1000)
    local data = visuals[key]
    if data then
        if data.Part then data.Part:Destroy() end
        visuals[key] = nil
    end
end

local function scanFullChunk(chunkX, chunkZ)
    local chunkName = chunkX .. "x" .. chunkZ
    if chunksScanned[chunkName] or scanning[chunkName] then return end
    
    local chunk = env.getChunk(chunkX, chunkZ)
    if not chunk or not chunk.blockdata then return end
    
    scanning[chunkName] = true
    local startX = chunkX * 16
    local startZ = chunkZ * 16
    local blockdata = chunk.blockdata

    for x = 0, 15 do
        if not module.enabled then break end
        
        local xData = blockdata[x]
        if not xData then continue end
        
        for y = 1, 63 do
            local yData = xData[y]
            if not yData then continue end
            
            for z = 0, 15 do
                local block = yData[z]
                if not block or block == 0 then continue end
                
                local id = type(block) == "table" and block.id or block
                if id and id ~= 0 then
                    local name = convertBlockIdToBlockName(id)
                    local color = getOreColor(name)
                    if color then
                        addVisual(startX + x, y, startZ + z, color, name, chunkName)
                    end
                end
            end
        end
        if x % 4 == 0 then RunService.Heartbeat:Wait() end
    end

    chunksScanned[chunkName] = true
    scanning[chunkName] = nil
end

ChunksFolder.ChildAdded:Connect(function(chunk)
    local coords = string.split(chunk.Name, "x")
    if #coords == 2 then
        local cx, cz = tonumber(coords[1]), tonumber(coords[2])
        if cx and cz then
            chunk:SetAttribute("ChunkX", cx)
            chunk:SetAttribute("ChunkZ", cz)
        end
    end
end)

ChunksFolder.ChildRemoved:Connect(function(chunk)
    chunksScanned[chunk.Name] = nil
    scanning[chunk.Name] = nil

    for key, data in pairs(visuals) do
        if data.Chunk == chunk.Name then
            if data.Part then data.Part:Destroy() end
            visuals[key] = nil
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not module.enabled then continue end
        for _, chunk in ipairs(ChunksFolder:GetChildren()) do
            if not chunksScanned[chunk.Name] then
                local cx = chunk:GetAttribute("ChunkX")
                local cz = chunk:GetAttribute("ChunkZ")
                if cx and cz then
                    task.spawn(scanFullChunk, cx, cz)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not module.enabled then
            if next(visuals) ~= nil then
                xrayfolder:ClearAllChildren()
                table.clear(visuals)
                table.clear(chunksScanned)
                table.clear(scanning)
            end
        end
    end
end)
