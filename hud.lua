-- ========================================================
-- RZIEZHA PREMIUM HUB V2 - AUTO DROPDOWN NO TYPING (MOBILE)
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Status Fitur (State)
local flyEnabled = false
local walkEnabled = false
local tpClickEnabled = false
local flySpeed = 70
local walkConnection, flyConnection

-- ========================================================
-- INSTANSIASI BASE GUI
-- ========================================================
local playerGui = player:WaitForChild("PlayerGui", 10)
if playerGui and playerGui:FindFirstChild("RziezhaHubGui") then
    playerGui.RziezhaHubGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RziezhaHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Tombol Open Kecil
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0.05, 0, 0.1, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
OpenButton.Text = "R"
OpenButton.TextColor3 = Color3.fromRGB(0, 255, 150)
OpenButton.TextSize = 20
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(0, 255, 150)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

-- FRAME UTAMA MOD MENU
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 240) -- Dipertinggi sedikit untuk list player
MainFrame.Position = UDim2.new(0.5, -140, 0.3, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 255, 150)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- HEADER MENU
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -40, 0, 35)
Header.Position = UDim2.new(0, 15, 0, 0)
Header.BackgroundTransparency = 1
Header.Text = "RZIEZHA PREMIUM HUB V2"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize = 15
Header.Font = Enum.Font.SourceSansBold
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = MainFrame

-- TOMBOL MINIMIZE
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 2)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
MinimizeBtn.TextSize = 20
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Parent = MainFrame

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -20, 0, 2)
Line.Position = UDim2.new(0, 10, 0, 35)
Line.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- CONTAINER UTAMA FITUR
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 42)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 400)
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container

-- Fungsi Pembuat Tombol
local function createModButton(text, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.SourceSansBold
    Btn.LayoutOrder = order
    Btn.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 50)
    Stroke.Thickness = 1
    Stroke.Parent = Btn

    return Btn, Stroke
end

-- ========================================================
-- AKTIVASI FITUR UTAMA
-- ========================================================

-- 1. FLY
local FlyBtn, FlyStroke = createModButton("🚀 Ultimate Fly: OFF", 1)
local function setupPhysics(character)
    if not character then return end
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root then return end
    if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
    if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end

    local bV = Instance.new("BodyVelocity")
    bV.Name = "FlyVelocity"
    bV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bV.Velocity = Vector3.new(0,0,0)
    bV.Parent = root

    local bG = Instance.new("BodyGyro")
    bG.Name = "FlyGyro"
    bG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bG.CFrame = camera.CFrame
    bG.Parent = root
    return bV, bG, root
end

FlyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    local char = player.Character
    if flyEnabled then
        FlyBtn.Text = "🚀 Ultimate Fly: ON"
        FlyBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        FlyStroke.Color = Color3.fromRGB(0, 255, 150)
        local bV, bG, root = setupPhysics(char)
        flyConnection = RunService.RenderStepped:Connect(function()
            if root and bV and bG then
                bG.CFrame = camera.CFrame
                bV.Velocity = camera.CFrame.LookVector * flySpeed
            end
        end)
    else
        FlyBtn.Text = "🚀 Ultimate Fly: OFF"
        FlyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        FlyStroke.Color = Color3.fromRGB(40, 40, 50)
        if flyConnection then flyConnection:Disconnect() end
        if char and char:FindFirstChild("HumanoidRootPart") then
            if char.HumanoidRootPart:FindFirstChild("FlyVelocity") then char.HumanoidRootPart.FlyVelocity:Destroy() end
            if char.HumanoidRootPart:FindFirstChild("FlyGyro") then char.HumanoidRootPart.FlyGyro:Destroy() end
        end
    end
end)

-- 2. MOUNTAIN WALK
local WalkBtn, WalkStroke = createModButton("⛰️ Mountain Walk: OFF", 2)
WalkBtn.MouseButton1Click:Connect(function()
    walkEnabled = not walkEnabled
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if walkEnabled then
        WalkBtn.Text = "⛰️ Mountain Walk: ON"
        WalkBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        WalkStroke.Color = Color3.fromRGB(0, 255, 150)
        walkConnection = RunService.RenderStepped:Connect(function()
            if hum and root and hum.Health > 0 then
                local moveDirection = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
                hum:Move(moveDirection, false)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {char}
                local raycastResult = workspace:Raycast(root.Position - Vector3.new(0, 1, 0), root.CFrame.LookVector * 4, raycastParams)
                if raycastResult then hum.Jump = true end
            end
        end)
    else
        WalkBtn.Text = "⛰️ Mountain Walk: OFF"
        WalkBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        WalkStroke.Color = Color3.fromRGB(40, 40, 50)
        if walkConnection then walkConnection:Disconnect() end
    end
end)

-- 3. TP CLICK
local TpClickBtn, TpClickStroke = createModButton("⚡ TP Click: OFF", 3)
TpClickBtn.MouseButton1Click:Connect(function()
    tpClickEnabled = not tpClickEnabled
    if tpClickEnabled then
        TpClickBtn.Text = "⚡ TP Click: ON"
        TpClickBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        TpClickStroke.Color = Color3.fromRGB(0, 255, 150)
    else
        TpClickBtn.Text = "⚡ TP Click: OFF"
        TpClickBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TpClickStroke.Color = Color3.fromRGB(40, 40, 50)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not tpClickEnabled then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local ray = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
            local res = workspace:Raycast(ray.Origin, ray.Direction * 1000)
            if res then root.CFrame = CFrame.new(res.Position + Vector3.new(0, 3, 0)) end
        end
    end
end)

-- ========================================================
-- 4. LIST PLAYER AUTOMATIC DROPDOWN (TANPA KETIK!)
-- ========================================================
local LabelPlr = Instance.new("TextLabel")
LabelPlr.Size = UDim2.new(1, -10, 0, 25)
LabelPlr.BackgroundTransparency = 1
LabelPlr.Text = "🎯 KLIK NAMA UNTUK TP:"
LabelPlr.TextColor3 = Color3.fromRGB(0, 255, 150)
LabelPlr.TextSize = 13
LabelPlr.Font = Enum.Font.SourceSansBold
LabelPlr.TextXAlignment = Enum.TextXAlignment.Left
LabelPlr.LayoutOrder = 4
LabelPlr.Parent = Container

local ListContainer = Instance.new("Frame")
ListContainer.Size = UDim2.new(1, -10, 0, 120)
ListContainer.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
ListContainer.LayoutOrder = 5
ListContainer.Parent = Container

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 6)
ListCorner.Parent = ListContainer

local ListScroll = Instance.new("ScrollingFrame")
ListScroll.Size = UDim2.new(1, -10, 1, -10)
ListScroll.Position = UDim2.new(0, 5, 0, 5)
ListScroll.BackgroundTransparency = 1
ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ListScroll.ScrollBarThickness = 3
ListScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ListScroll.Parent = ListContainer

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ListScroll

-- Fungsi Update Daftar Nama Player
local function updatePlayerList()
    for _, child in pairs(ListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local currentOrder = 1
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local PlrBtn = Instance.new("TextButton")
            PlrBtn.Size = UDim2.new(1, -5, 0, 28)
            PlrBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
            PlrBtn.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
            PlrBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
            PlrBtn.TextSize = 12
            PlrBtn.Font = Enum.Font.SourceSans
            PlrBtn.TextXAlignment = Enum.TextXAlignment.Left
            PlrBtn.Parent = ListScroll
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = PlrBtn

            -- Aksi Klik Langsung Teleport
            PlrBtn.MouseButton1Click:Connect(function()
                local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and myRoot then
                    myRoot.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
                end
            end)

            currentOrder = currentOrder + 1
        end
    end
    ListScroll.CanvasSize = UDim2.new(0, 0, 0, currentOrder * 33)
end

-- Amati Server (Jika ada player masuk/keluar langsung sinkron otomatis)
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList() -- Jalankan scan pertama
