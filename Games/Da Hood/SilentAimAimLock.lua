-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Examples/AimLock.lua"))()
local AimingChecks = Aiming.Checks
local AimingSelected = Aiming.Selected
local AimLockSettings = Aiming.AimLock

-- // Services
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- // Vars
local CurrentCamera = Workspace.CurrentCamera
local AimEnabled = false -- Estado inicial: Apagado

local DaHoodSettings = {
    Prediction = 0.165,
    SilentAim = true,
    AimLock = AimLockSettings,
    BeizerLock = {
        Smoothness = 0.05,
        CurvePoints = {
            Vector2.new(0.83, 0),
            Vector2.new(0.17, 1)
        }
    }
}
getgenv().DaHoodSettings = DaHoodSettings

-- // Lógica de Toggle con la tecla Q
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Q then
        AimEnabled = not AimEnabled
        -- Opcional: Para ver si funciona, mira tu consola (F9)
        warn("AimLock State: " .. (AimEnabled and "ON" or "OFF"))
    end
end)

-- // Hook (Silent Aim)
local __index
__index = hookmetamethod(game, "__index", function(t, k)
    -- Solo funciona si AimEnabled es true
    if (AimEnabled and t:IsA("Mouse") and (k == "Hit" or k == "Target") and AimingChecks.IsAvailable() and DaHoodSettings.SilentAim) then
        local SelectedPart = AimingSelected.Part
        local Hit = DaHoodSettings.ApplyPredictionFormula(SelectedPart, AimingSelected.Velocity * Vector3.new(1, 0.1, 1))
        return (k == "Hit" and Hit or SelectedPart)
    end
    return __index(t, k)
end)

-- // Aimlock position
function AimLockSettings.AimLockPosition(CameraMode)
    if not AimEnabled then return nil, {} end -- Si está apagado, no devuelve nada
    
    local Hit = DaHoodSettings.ApplyPredictionFormula(AimingSelected.Part)
    local HitPosition = Hit.Position

    if (CameraMode) then
        return HitPosition, {}
    else
        local Vector, _ = CurrentCamera:WorldToViewportPoint(HitPosition)
        return Vector2.new(Vector.X, Vector.Y), {
            Smoothness = DaHoodSettings.BeizerLock.Smoothness,
            CurvePoints = DaHoodSettings.BeizerLock.CurvePoints
        }
    end
end

-- // Helper
function DaHoodSettings.ApplyPredictionFormula(SelectedPart, Velocity)
    return SelectedPart.CFrame + ((Velocity or Vector3.new(0,0,0)) * DaHoodSettings.Prediction)
end

return DaHoodSettings
