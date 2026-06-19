local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalEntity = require(ReplicatedStorage:WaitForChild("LocalEntity"))
local StaticCollisionCheck = require(ReplicatedStorage:WaitForChild("StaticCollisionCheck"))

local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

_G.Movement = _G.Movement or {
    hooked = false,
    Fly = false,
    Noclip = false,
    NoFall = false,
    FlySpeed = 0.4,
    NoclipSpeed = 1 / 1.25
}

if _G.Movement.hooked then
    return
end
_G.Movement.hooked = true

local old
old = hookfunction(LocalEntity, function(state, env, dt)
    if not state then
        return old(state, env, dt)
    end

    local _, collisionInfo = StaticCollisionCheck(env, state, state.Size)
    local inFluid = collisionInfo.inWater or collisionInfo.inLava

    if inFluid then
        state.FallDistance = nil
    end

    local mv = Vector3.zero
    local cf = Camera.CFrame

    if UIS:IsKeyDown(Enum.KeyCode.W) then mv += cf.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then mv -= cf.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then mv += cf.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then mv -= cf.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv -= Vector3.yAxis end

    if _G.Movement.NoFall and not inFluid then
        state.FallDistance = nil
    end

    if _G.Movement.Fly then
        if not inFluid then
            state.FallDistance = nil
        end
        state.Motion = mv.Magnitude > 0
            and mv.Unit * _G.Movement.FlySpeed
            or Vector3.zero

    elseif _G.Movement.Noclip then
        if not inFluid then
            state.FallDistance = nil
        end
        if mv.Magnitude > 0 then
            state.Pos += mv.Unit * _G.Movement.NoclipSpeed
        end
        state.Motion = Vector3.zero
    end

    return old(state, env, dt)
end)
