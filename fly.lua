-- FLY SCRIPT MOBILE (KONTROL PENUH PAKAI TOMBOL LOMPAT)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- ========================================================
-- ATUR KECEPATAN DI SINI:
-- Ganti angka 60 di bawah sesuai keinginan Anda.
-- Contoh: 30 (Lambat), 60 (Normal), 120 (Cepat), 200 (Sangat Cepat)
local speed = 60 
-- ========================================================

-- Bersihkan objek lama biar gak numpuk
if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end

local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.Name = "FlyVelocity"
bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
bodyVelocity.Parent = root

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.Name = "FlyGyro"
bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
bodyGyro.Parent = root

-- Anti-Mogok pas mati
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if bodyVelocity and bodyGyro and root then
        bodyVelocity.Parent = root
        bodyGyro.Parent = root
    end
end)

-- Loop Sistem Kontrol
RunService.RenderStepped:Connect(function()
    if root and bodyVelocity and bodyGyro and humanoid then
        bodyGyro.CFrame = camera.CFrame
        
        -- LOGIKA KONTROL:
        -- Tahan tombol LOMPAT untuk MAJU ke arah kamera.
        -- Lepas tombol lompat untuk BERHENTI DIAM di udara (Ngerem).
        if humanoid.Jump then
            bodyVelocity.Velocity = camera.CFrame.LookVector * speed
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
