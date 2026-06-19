-- original: https://raw.githubusercontent.com/SUUUUUS00000/MEGGD-Anti-kick/refs/heads/main/MEGGD%20Best%20Anti-kick.lua
local a1 = getfenv().getgc or getgc
local b1 = getfenv().hookfunction or hookfunction
local c1 = getfenv().newcclosure or function(f) return f end
local d1 = getfenv().hookmetamethod or hookmetamethod
local h1 = getfenv().getnamecallmethod or getnamecallmethod

local p = game:GetService("Players").LocalPlayer
local R = {}

local function F(r)
    if R[r] then return true end
    local n = r.Name
    if #n == 36 and string.match(n, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
        R[r] = true
        return true
    end
    return false
end

local o
o = hookfunction(Instance.new("RemoteEvent").FireServer, function(s, ...)
    local a = {...}
    if F(s) then return o(s, ...) end
    for _, v in ipairs(a) do
        if type(v) == "string" and string.find(string.lower(v), "kick") then return end
    end
    return o(s, ...)
end)

local n
n = d1(game, "__namecall", c1(function(s, ...)
    local m = h1()
    if s == p and (m == "Kick" or m == "kick" or m == "Destroy" or m == "destroy") then return end
    return n(s, ...)
end))

local k
k = b1(p.Kick, c1(function(self, ...)
    if not checkcaller() and self == p then return end
    return k(self, ...)
end))

local D
D = b1(p.Destroy, c1(function(self, ...)
    if not checkcaller() and self == p then return end
    return D(self, ...)
end))

pcall(function()
    for _, v in pairs(a1(true)) do
        if type(v) == "table" then
            pcall(function()
                if rawget(v, "Send") and type(rawget(v, "Send")) == "function" and rawget(v, "Get") and rawget(v, "Encrypt") then
                    local s_send
                    s_send = b1(v.Send, c1(function(cmd, ...)
                        if type(cmd) == "string" then
                            local c = string.lower(cmd)
                            if c == "detected" or c == "logerror" then return end
                        end
                        return s_send(cmd, ...)
                    end))
                end
                if rawget(v, "Kill") and type(rawget(v, "Kill")) == "function" and rawget(v, "Disconnect") then
                    b1(v.Kill, c1(function(...) return end))
                    b1(v.Disconnect, c1(function(...) return end))
                end
            end)
        end
    end
end)
task.wait()
local oldhmmi
local oldhmmnc
oldhmmi = hookmetamethod(game, "__index", function(self, method)
    if self == player and method:lower() == "kick" then
        return error("Expected ':' not '.' calling member function Kick", 2)
    end
    return oldhmmi(self, method)
end)

oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
    if self == player and getnamecallmethod():lower() == "kick" then
        return
    end
    return oldhmmnc(self, ...)
end)
