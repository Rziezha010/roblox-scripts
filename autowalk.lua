-- ========================================================
-- SCRIPT AUTO WALK + AUTOMATIC JUMP SENSOR (MAP GUNUNG)
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local autoWalkEnabled = false
local walkConnection = nil

-- Pastikan karakter tetap terdeteksi saat respawn
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")
end)

-- ========================================================
-- MEMBUAT TOMBOL ON/OFF DI LAYAR HP
-- ========================================================
local playerGui = player:WaitForChild("PlayerGui", 10)
if playerGui then
    if playerGui:FindFirstChild("AutoWalkGui") then
        playerGui.AutoWalkGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoWalkGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = playerGui

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "AutoWalkToggle"
    ToggleButton.Size = UDim2.new(0, 150, 0, 50)
    ToggleButton.Position = UDim2.new(0.75, -10, 0.25, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleButton.BackgroundTransparency = 0.3
    ToggleButton.Text = "Mountain Walk: OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 75, 75)
    ToggleButton.TextSize = 15
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.Active = true
    ToggleButton.Draggable = true
    ToggleButton.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = ToggleButton

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 75, 75)
    UIStroke.Thickness = 2
    UIStroke.Parent = ToggleButton

    -- LOGIKA SENSOR JALAN & LOMPAT AUTOMATIS
    ToggleButton.MouseButton1Click:Connect(function()
        autoWalkEnabled = not autoWalkEnabled
        
        if autoWalkEnabled then
            ToggleButton.Text = "Mountain Walk: ON"
            ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 150)
            UIStroke.Color = Color3.fromRGB(0, 255, 150)
            
            -- Jalankan sistem pemindaian rintangan real-time
            walkConnection = RunService.RenderStepped:Connect(function()
                if humanoid and root and humanoid.Health > 0 then
                    -- 1. Paksa Karakter Jalan Maju Mengikuti Kamera
                    local direction = workspace.CurrentCamera.CFrame.LookVector
                    local moveDirection = Vector3.new(direction.X, 0, direction.Z).Unit
                    humanoid:Move(moveDirection, false)
                    
                    -- 2. SENSOR LASER (Mata Samping & Depan)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    
                    -- Tembakkan laser sejauh 4 pejantan (studs) ke depan dada
                    local originOffset = root.Position - Vector3.new(0, 1, 0) -- Setinggi kaki ke dada
                    local rayDirection = root.CFrame.LookVector * 4
                    
                    local raycastResult = workspace:Raycast(originOffset, rayDirection, raycastParams)
                    
                    -- Jika laser menabrak rintangan (batu/tangga/tebing Sumbing)
                    if raycastResult then
                        -- Paksa melompat dengan jeda tipis agar lompatannya sempurna melewati celah
                        humanoid.Jump = true
                    end
                end
            end)
        else
            ToggleButton.Text = "Mountain Walk: OFF"
            ToggleButton.TextColor3 = Color3.fromRGB(255, 75, 75)
            UIStroke.Color = Color3.fromRGB(255, 75, 75)
            
            if walkConnection then
                walkConnection:Disconnect()
                walkConnection = nil
            end
        end
    end)
end
