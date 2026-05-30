-- ========================================================
-- SCRIPT TERBANG MOBILE (VERSI FIX 100% - AMAN EXECUTOR)
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local speed = 70 -- Kecepatan terbang Anda
local isFlyingAndMoving = false

-- Fungsi menyiapkan fisik terbang pada karakter
local function setupPhysics(character)
    if not character then return end
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root then return end
    
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

-- Ambil karakter saat ini
local currentCharacter = player.Character or player.CharacterAdded:Wait()
local bodyVelocity, bodyGyro, root = setupPhysics(currentCharacter)

-- Aktifkan kembali saat respawn
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    bodyVelocity, bodyGyro, root = setupPhysics(newChar)
end)

-- ========================================================
-- GUI LAYAR MOBILE
-- ========================================================
local playerGui = player:WaitForChild("PlayerGui", 10)
if playerGui then
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
    FlyButton.Size = UDim2.new(0, 80, 0, 80)
    FlyButton.Position = UDim2.new(0.75, 0, 0.35, 0)
    FlyButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    FlyButton.BackgroundTransparency = 0.3
    FlyButton.Text = "FLY"
    FlyButton.TextColor3 = Color3.fromRGB(0, 255, 150)
    FlyButton.TextSize = 22
    FlyButton.Font = Enum.Font.SourceSansBold
    FlyButton.Active = true
    FlyButton.Draggable = true
    FlyButton.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = FlyButton

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 255, 150)
    UIStroke.Thickness = 3
    UIStroke.Parent = FlyButton

    -- Logika sentuhan mobile
    local function onTouchStart()
        isFlyingAndMoving = true
        FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        UIStroke.Color = Color3.fromRGB(255, 50, 50)
    end

    local function onTouchEnd()
        isFlyingAndMoving = false
        FlyButton.TextColor3 = Color3.fromRGB(0, 255, 150)
        UIStroke.Color = Color3.fromRGB(0, 255, 150)
    end

    FlyButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            onTouchStart()
        end
    end)

    FlyButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            onTouchEnd()
        end
    end)
end

-- Loop pergerakan utama
RunService.RenderStepped:Connect(function()
    if root and bodyVelocity and bodyGyro then
        bodyGyro.CFrame = camera.CFrame
        
        if isFlyingAndMoving then
            bodyVelocity.Velocity = camera.CFrame.LookVector * speed
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
