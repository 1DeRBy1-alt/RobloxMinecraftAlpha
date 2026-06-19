if getgenv().hitboxLoaded then return end
getgenv().hitboxLoaded = true

local Entities = workspace:WaitForChild("Entities")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local originalStats = {}

local module = getgenv().ModuleManager.new("HitboxExpander", {
    size = 9,
    teamCheck = true,
})

task.spawn(function()
    while task.wait(0.25) do
        local size = module:get("size") or 9
        local enabled = module.enabled

        if not enabled then
            if next(originalStats) ~= nil then
                for hb, stats in pairs(originalStats) do
                    if hb and hb.Parent then
                        hb.Size = stats.Size
                        hb.Transparency = stats.Transparency
                        hb.Color = stats.Color
                    end
                end
                table.clear(originalStats)
            end
            continue
        end

        for _, ent in ipairs(Entities:GetChildren()) do
            if module:get("teamCheck") then
                local targetPlayer = Players:FindFirstChild(ent.Name)
                if targetPlayer and targetPlayer ~= localPlayer and targetPlayer.Team == localPlayer.Team then
                    continue
                end
            end

            local hb = (ent.Name == "playerhitbox" and ent) or ent:FindFirstChild("playerhitbox")

            if hb and hb:IsA("BasePart") then
                if not originalStats[hb] then
                    originalStats[hb] = {
                        Size = hb.Size,
                        Transparency = hb.Transparency,
                        Color = hb.Color
                    }
                end

                hb.Size = Vector3.new(size, size, size)
                hb.Transparency = 0.7
                hb.Color = Color3.fromRGB(255, 0, 0)
                hb.CanCollide = false
            end
        end
    end
end)

Entities.ChildRemoved:Connect(function(ent)
    local hb = (ent.Name == "playerhitbox" and ent) or ent:FindFirstChild("playerhitbox")
    if hb then
        originalStats[hb] = nil
    end
end)
