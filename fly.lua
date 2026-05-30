-- FLY SCRIPT MOBILE (SUPER SIMPLE & FORCED MOVE)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

local speed = 60 -- Anda bisa ganti angka ini untuk mengatur kecepatan terbang

-- Bersihkan objek lama agar tidak menumpuk dan bikin lag
if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end

-- Membuat daya dorong terbang baru yang stabil untuk mobile
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.Name = "FlyVelocity"
bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
bodyVelocity.Parent = root

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.Name = "FlyGyro"
bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
bodyGyro.Parent = root

-- Anti-Mogok Pasca Mati (Otomatis aktif lagi saat respawn)
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
    if bodyVelocity and bodyGyro and root then
        bodyVelocity.Parent = root
        bodyGyro.Parent = root
    end
end)

-- Loop Utama: Memaksa karakter bergerak mengikuti arah pandangan kamera HP
RunService.RenderStepped:Connect(function()
    if root and bodyVelocity and bodyGyro then
        bodyGyro.CFrame = camera.CFrame
        local direction = camera.CFrame.LookVector
        bodyVelocity.Velocity = direction * speed
    end
end)
