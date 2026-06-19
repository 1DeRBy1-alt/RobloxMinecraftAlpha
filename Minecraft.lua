local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))()
if getgenv().spectraLoadedMC then
    AkaliNotif.Notify({
        Title = "Spectra Client",
        Description = "Script is already loaded!",
        Duration = 5
    })
    return
end
getgenv().spectraLoadedMC = true

-- Anti Kick --
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/refs/heads/main/Modules/anti_kick.lua", true))()

repeat task.wait(0.5) until workspace:FindFirstChild("Chunks") and workspace:FindFirstChild("Entities")

AkaliNotif.Notify({
    Title = "Spectra Client",
    Description = "Script is loading...",
    Duration = 3
})

-- Module Manager --
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/refs/heads/main/Modules/ModuleManager.lua", true))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/main/Modules/XRay.lua", true))() -- XRay
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/refs/heads/main/Modules/Scaffold.lua", true))() -- Scaffold
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/main/Modules/Killaura.lua", true))() -- Killaura
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/refs/heads/main/Modules/Mob%20Killaura.lua", true))() -- Mob Killaura
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/refs/heads/main/Modules/ChestStealer.lua", true))() -- Chest Stealer
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/main/Modules/Movement/init.lua", true))() -- Movement
loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/refs/heads/main/Modules/hitbox_expander.lua"))() -- Hitbox Expander

local MM = getgenv().ModuleManager
local kaModule = MM.get("Killaura")
local mobKaModule = MM.get("MobKillaura")
local hbModule = MM.get("HitboxExpander")
local scaffoldModule = MM.get("Scaffold")
local xrayModule = MM.get("XRay")
local chestModule = MM.get("ChestStealer")

-- UI Library --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- Variables --
local player = Players.LocalPlayer
local isPC, isMobile
local UpdatePlayer = ReplicatedStorage:WaitForChild("UpdatePlayer", 10)

if UIS.KeyboardEnabled and UIS.MouseEnabled then
    isPC = true
    AkaliNotif.Notify({
        Title = "PC Detected!",
        Description = "PC Detected, Movement features should work...",
        Duration = 3
    })
elseif UIS.TouchEnabled then
    isMobile = true
    AkaliNotif.Notify({
        Title = "Mobile Device Detected!",
        Description = "Mobile Detected, executing button...",
        Duration = 3
    })
    loadstring(game:HttpGet("https://raw.githubusercontent.com/screengui/mods/refs/heads/main/btn.lua", true))()
end

local Window = Fluent:CreateWindow({
    Title = "Minecraft (Spectra Client) v1.3.5",
    SubTitle = "by 1DeRBy1",
    TabWidth = 160,
    Size = UDim2.fromOffset(560, 340),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Credits = Window:AddTab({ Title = "Credits", Icon = "info" }),
    cs = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    lp = Window:AddTab({ Title = "Player", Icon = "user" }),
    wr = Window:AddTab({ Title = "World", Icon = "globe" }),
    vs = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    ms = Window:AddTab({ Title = "Misc", Icon = "box" }),
    st = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

-- World Functions --
local WorldFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeRBy1-alt/RobloxMinecraftAlpha/refs/heads/main/WorldFunctions.lua"))()

-- Credits Tab --
Tabs.Credits:AddParagraph({
    Title = "Made by 1DeRBy1",
    Content = "UI Library: Fluent\nv1.3.5\nOpen-Sourced\n\nCredits:\nPurpleApple: Mobile button and logo"
})

-- Combat Tab --
local kaToggle = Tabs.cs:AddToggle("kaToggle", {
    Title = "Kill Aura",
    Description = "Automatically attacks nearby players",
    Default = false,
    Callback = function(t)
        if t then kaModule:start() else kaModule:stop() end
    end
})

local mobKaToggle = Tabs.cs:AddToggle("mobKaToggle", {
    Title = "Mob Killaura",
    Description = "Automatically attacks nearby mobs",
    Default = false,
    Callback = function(t)
        if t then mobKaModule:start() else mobKaModule:stop() end
    end
})

local hbToggle = Tabs.cs:AddToggle("hbToggle", {
    Title = "Hitbox Expander",
    Description = "Automatically expands all player hitboxes (W.I.P)",
    Default = false,
    Callback = function(t)
        if t then hbModule:start() else hbModule:stop() end
    end
})

if isMobile then
    Tabs.lp:AddButton({
        Title = "Mobile Fly",
        Description = "Allows you to fly around the map (Mobile)",
        Callback = function()
            if firesignal then
                firesignal(UpdatePlayer.OnClientEvent, "fly")
            end
        end
    })
end

-- Player Tab --
local flyToggle = Tabs.lp:AddToggle("flyToggle", {
    Title = "Fly",
    Description = "Allows you to fly around the map",
    Default = false,
    Callback = function(t) _G.Movement.Fly = t end
})

local noclipToggle = Tabs.lp:AddToggle("noclipToggle", {
    Title = "Noclip",
    Description = "Like flying, but through walls.",
    Default = false,
    Callback = function(t) _G.Movement.Noclip = t end
})

local noFallToggle = Tabs.lp:AddToggle("nofallToggle", {
    Title = "No Fall",
    Description = "Removes fall damage",
    Default = false,
    Callback = function(t) _G.Movement.NoFall = t end
})

-- Visuals Tab --
local xrayToggle = Tabs.vs:AddToggle("xrayToggle", {
    Title = "X-Ray",
    Description = "ESP for ores.",
    Default = false,
    Callback = function(t)
        if t then xrayModule:start() else xrayModule:stop() end
    end
})

local blackCoverToggle = Tabs.vs:AddToggle("blackCoverToggle", {
    Title = "No Black Cover",
    Description = "Hides that annoying UI blacking out your screen",
    Default = false,
    Callback = function(t)
        local playerGui = player.PlayerGui
        if playerGui and playerGui:FindFirstChild("MainGui") and playerGui.MainGui:FindFirstChild("BlackCover") then
            playerGui.MainGui.BlackCover.BackgroundTransparency = t and 1 or 0
        end
    end
})

-- World Tab --
local scaftog = Tabs.wr:AddToggle("scaftog", {
    Title = "Scaffold",
    Description = "Automatically places blocks below feet",
    Default = false,
    Callback = function(t)
        if t then scaffoldModule:start() else scaffoldModule:stop() end
    end
})

Tabs.wr:AddToggle("chestStealerToggle", {
    Title = "Chest Stealer",
    Description = "Automatically loots chests (EXPERIMENTAL)",
    Default = false,
    Callback = function(t)
        if t then chestModule:start() else chestModule:stop() end
    end
})

-- Misc Tab --
Tabs.ms:AddButton({
    Title = "Rejoin",
    Description = "Rejoin the game",
    Callback = function()
        Fluent:Notify({Title = "Rejoin", Content = "Rejoining...", Duration = 2})
        task.wait(0.9)
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

local suicideButton = Tabs.ms:AddButton({
    Title = "Suicide",
    Description = "Instantly kill yourself",
    Callback = function()
        UpdatePlayer:FireServer("damage", "generic", 1e17)
    end
})

-- Settings Tab --
Tabs.st:AddInput("kadelay", {
    Title = "Kill Aura Delay",
    Description = "Seconds between each hit",
    Default = "0.05",
    Placeholder = "Enter a number",
    Numeric = true,
    Finished = false,
    Callback = function(kad)
        local newDelay = tonumber(kad)
        if newDelay then
            kaModule:set("delay", newDelay)
            mobKaModule:set("delay", newDelay)
            Fluent:Notify({Title = "Success!", Content = "Delay set to: " .. newDelay, Duration = 3})
        else
            Fluent:Notify({Title = "Error", Content = "Please enter a valid number", Duration = 3})
        end
    end
})

Tabs.st:AddSlider("hbSize", {
    Title = "Hitbox Size",
    Description = "Adjust the size of the expanded hitboxes",
    Default = 9,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Callback = function(hbs)
        hbModule:set("size", hbs)
    end
})

Tabs.st:AddToggle("kaTeamCheckToggle", {
    Title = "Team Check",
    Description = "If enabled, Killaura/Hitboxes will ignore teammates",
    Default = true,
    Callback = function(t)
        kaModule:set("teamCheck", t)
        hbModule:set("teamCheck", t)
    end
})

Tabs.st:AddInput("chestDelay", {
    Title = "Chest Stealer Delay",
    Description = "Seconds between each loot cycle",
    Default = "0.5",
    Placeholder = "Enter a number",
    Numeric = true,
    Finished = false,
    Callback = function(cd)
        local newDelay = tonumber(cd)
        if newDelay then
            chestModule:set("delay", newDelay)
            Fluent:Notify({Title = "Success!", Content = "Delay set to: " .. newDelay, Duration = 2})
        else
            Fluent:Notify({Title = "Error", Content = "Please enter a valid number", Duration = 1})
        end
    end
})

Tabs.st:AddSlider("flySpeed", {
    Title = "Fly Speed",
    Description = "Change your flying speed",
    Default = 0.4,
    Min = 0.1,
    Max = 0.9,
    Rounding = 1,
    Callback = function(fs)
        _G.Movement.FlySpeed = fs
    end
})

Tabs.st:AddSlider("noclipSpeed", {
    Title = "Noclip Speed",
    Description = "Change your noclip speed",
    Default = 0.8,
    Min = 0.1,
    Max = 0.9,
    Rounding = 1,
    Callback = function(ns)
        _G.Movement.NoclipSpeed = ns
    end
})

Tabs.st:AddDropdown("InterfaceTheme", {
    Title = "Theme",
    Description = "Changes the interface theme.",
    Values = Fluent.Themes,
    Default = Fluent.Theme,
    Callback = function(theme)
        Fluent:SetTheme(theme)
    end
})

Tabs.st:AddToggle("TransparentToggle", {
    Title = "Transparency",
    Description = "Makes the interface transparent.",
    Default = Fluent.Transparency,
    Callback = function(t)
        Fluent:ToggleTransparency(t)
    end
})

Window:SelectTab(1)
