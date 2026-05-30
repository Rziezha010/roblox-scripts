-- FLY SCRIPT MOBILE (DENGAN TOMBOL SELEKSI KHUSUS DI KANAN BAWAH)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

local speed = 70 -- Kecepatan terbang
local isFlyingAndMoving = false

-- Bersihkan objek fisik lama jika ada
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

-- MEMBUAT FRAME GUI BARU YANG LEBIH RAPI
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

local FlyButton = Instance.new("TextButton")
FlyButton.Name = "FlyControlButton"
-- Ukuran disesuaikan jadi lebih pas untuk jempol HP (60x60)
FlyButton.Size = UDim2.new(0, 60, 0, 60)
-- Posisi dipindah ke kanan bawah (Dekat area tombol lompat default)
FlyButton.Position = UDim2.new(0.85, -10, 0.65, -10) 
FlyButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FlyButton.BackgroundTransparency = 0.4 -- Transparan elegan agar tidak menutupi map
-- Desain Teks
FlyButton.Text = "FLY"
FlyButton.TextColor3 = Color3.fromRGB(0, 255, 150) -- Teks warna hijau neon terang
FlyButton.TextSize = 16
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.Active = true
FlyButton.Draggable = true -- Tetap bisa digeser manual jika kurang pas
FlyButton.Parent = ScreenGui

-- Efek Sudut Bulat Sempurna
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FlyButton

-- Efek Garis Pinggir (Glow UI)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 150)
UIStroke.Thickness = 2
UIStroke.Parent = FlyButton

-- Logika Sentuhan Tombol Mobile
FlyButton.MouseButton1Down:Connect(function()
    isFlyingAndMoving = true
    FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UIStroke.Color = Color3.fromRGB(255, 50, 50) -- Pinggiran berubah merah saat ditekan
end)

FlyButton.MouseButton1Up:Connect(function()
    isFlyingAndMoving = false
    FlyButton.TextColor3 = Color3.fromRGB(0, 255, 150)
    UIStroke.Color = Color3.fromRGB(0, 255, 150) -- Kembali ke hijau semula
end)

FlyButton.MouseLeave:Connect(function()
    isFlyingAndMoving = false
    FlyButton.TextColor3 = Color3.fromRGB(0, 255, 150)
    UIStroke.Color = Color3.fromRGB(0, 255, 150)
end)

-- Anti-Mogok pas mati (Respawn Handler)
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
    if bodyVelocity and bodyGyro and root then
        bodyVelocity.Parent = root
        bodyGyro.Parent = root
    end
end)

-- Loop Per
