-- ========================================================
-- RZIEZHA PREMIUM HUB V8 - MINIMALIST TELEPORT EDITION (2026)
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local isBypassTpActive = false

-- Cleanup Gui Lama
local playerGui = player:WaitForChild("PlayerGui", 5)
if playerGui and playerGui:FindFirstChild("RziezhaHubGui") then
    playerGui.RziezhaHubGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RziezhaHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Frame Utama (Minimalis)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Header
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Text = "RZIEZHA TELEPORT HUB"
Header.TextColor3 = Color3.fromRGB(255, 50, 50)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 14
Header.Parent = MainFrame

-- Container Player List
local ListScroll = Instance.new("ScrollingFrame")
ListScroll.Size = UDim2.new(1, -20, 1, -60)
ListScroll.Position = UDim2.new(0, 10, 0, 50)
ListScroll.BackgroundTransparency = 1
ListScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
ListScroll.ScrollBarThickness = 2
ListScroll.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ListScroll

-- Logika Teleport Aman
local function bypassStreamingTp(targetPlayer)
    if isBypassTpActive then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end
    local tChar = targetPlayer.Character
    if not tChar or not tChar.PrimaryPart then return end
    
    isBypassTpActive = true
    local bf = Instance.new("BodyForce")
    bf.Force = Vector3.new(0, workspace.Gravity * root:GetMass(), 0)
    bf.Parent = root
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local tPart = targetPlayer.Character and (targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character.PrimaryPart)
        if tPart and root and hum and hum.Health > 0 then
            local targetPos = tPart.Position + Vector3.new(0, 4, 0)
            local myPos = root.Position
            if (targetPos - myPos).Magnitude < 12 then
                if conn then conn:Disconnect() end
                bf:Destroy()
                isBypassTpActive = false
                return
            end
            root.Velocity = (targetPos - myPos).Unit * 450
            root.CFrame = CFrame.new(myPos, Vector3.new(targetPos.X, myPos.Y, targetPos.Z))
        else
            if conn then conn:Disconnect() end
            bf:Destroy()
            isBypassTpActive = false
        end
    end)
end

-- Update List Player
local function updatePlayerList()
    for _, child in pairs(ListScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            Btn.Text = "🎯 " .. p.DisplayName
            Btn.TextColor3 = Color3.fromRGB(25
                
