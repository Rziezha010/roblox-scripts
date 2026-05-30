-- ========================================================
-- SCRIPT TERBANG MOBILE (VERSI FINAL - KOREKSI TOTAL ANTI-GAGAL)
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("InputService") or game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local speed = 70 -- Kecepatan terbang default
local isFlyingAndMoving = false

-- Fungsi Utama untuk Menyiapkan Fisika Terbang pada Karakter
local function setupPhysics(character)
    if not character then return end
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root then return end
    
    -- Bersihkan objek lama agar tidak menumpuk
    if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
    if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "FlyGyro"
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.CFrame = camera.CFrame
    bodyGyro.Parent = root

    return bodyVelocity, bodyGyro, root
end

-- Ambil karakter saat ini dan siapkan fisika awal
local currentCharacter = player.Character or player.CharacterAdded:Wait()
local bodyVelocity, bodyGyro, root = setupPhysics(currentCharacter)

-- Otomatis aktifkan kembali fisika terbang saat karakter respawn/mati
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    bodyVelocity, bodyGyro, root = setupPhysics(newChar)
end)

-- ========================================================
-- PEMBUATAN GUI LAYAR MOBILE (DIJAMIN MUNCUL DI SEMUA EXECUTOR)
-- ========================================================
local playerGui = player:WaitForChild("PlayerGui", 10)
if playerGui then
    -- Hapus GUI lama jika sempat terpasang agar tidak menumpuk
    if playerGui:FindFirstChild("FlyScreenGui") then
        playerGui.FlyScreenGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FlyScreenGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = playerGui

    local FlyButton = Instance.new("TextButton")
    FlyButton.Name = "FlyControlButton"
    FlyButton.Size = UDim2.new(0, 80, 0, 80) -- Ukuran pas dan besar di layar HP
    FlyButton.Position = UDim2.new(0.75, 0, 0.35, 0) -- Posisi aman di area kanan tengah layar (di atas tombol jump)
    FlyButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    FlyButton.BackgroundTransparency = 0.3
    FlyButton.Text = "FLY"
    FlyButton.TextColor3 = Color3.fromRGB(0, 255, 150) -- Hijau neon menyala
    FlyButton.TextSize = 22
    FlyButton.Font = Enum.Font.SourceSansBold
    FlyButton.Active = true
    FlyButton.Draggable = true -- Bisa Anda geser manual jika posisinya menutupi tombol game
    FlyButton.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
