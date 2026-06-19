-- Services --
local Players = game:GetService("Players")

-- Variables --
local player = Players.LocalPlayer
local lastHit = 0
local MAX_RANGE = 16

local module = getgenv().ModuleManager.new("Killaura", {
    delay = 0.05,
    teamCheck = true,
})

-- Functions --
local function getClosestPlayer()
    local closest = nil
    local shortest = math.huge
    local myChar = player.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if not myHrp then return nil end

    local myTeam = player.Team

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if module:get("teamCheck") then
                local pTeam = p.Team
                if myTeam and pTeam and myTeam.TeamColor == pTeam.TeamColor then
                    continue
                end
            end

            local dist = (myHrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist <= MAX_RANGE and dist < shortest then
                shortest = dist
                closest = p
            end
        end
    end
    return closest
end

if not getgenv().kaHooked then
    getgenv().kaHooked = true
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() and module.enabled and (method == "InvokeServer" or method == "invokeServer") and self.Name == "SendState" then
            local data = args[1]
            if type(data) == "table" then
                if (data.ibreak or data.ibroken or data.ieaten or data.iuse or data.iinteract or data.icraft) then
                    return oldNamecall(self, ...)
                end

                local currentTime = tick()
                local delayTime = module:get("delay") or 0.05

                if (currentTime - lastHit) >= delayTime then
                    local closest = getClosestPlayer()
                    if closest then
                        data.targetEntity = closest.Name
                        data.iattack = true
                        lastHit = currentTime
                    elseif not data.targetEntity then
                        data.targetEntity = ""
                    end
                else
                    data.iattack = false
                end

                return self.InvokeServer(self, data)
            end
        end

        return oldNamecall(self, ...)
    end)
end
