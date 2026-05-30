-- ========================================================
-- RZIEZHA PREMIUM HUB V7.2 - LITE & HYPER-OPTIMIZED (2026)
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- State Fitur
local flyEnabled = false
local walkEnabled = false
local tpClickEnabled = false
local isBypassTpActive = false
local flySpeed = 70
local walkConnection, flyConnection

-- ========================================================
-- CLEANUP SYSTEM (Mencegah Crash Saat Di-execute Ulang)
-- ========================================================
local playerGui = player:WaitForChild("PlayerGui", 5)
if playerGui and playerGui:FindFirstChild("RziezhaHubGui") then
    playerGui.RziezhaHubGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RziezhaHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Tombol Open Minimalis (Muncul kalau Menu di-minimize)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 40, 0, 40)
OpenButton.Position = UDim2.new(0.02, 0, 0.2, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(20, 15, 15)
OpenButton.Text = "RZ"
OpenButton.TextColor3 = Color3.fromRGB(255, 50, 50)
OpenButton.TextSize = 14
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

-- FRAME UTAMA MOD MENU (SIDEBAR NAV)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 440, 0, 240)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- HEADER ATAS
local HeaderText = Instance.new("TextLabel")
HeaderText.Size = UDim2.new(1, -50, 0, 35)
HeaderText.Position = UDim2.new(0, 12, 0, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.Text = "RziezhaHub - <font color='#ff3232'>Universal</font>"
HeaderText.RichText = true
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.TextSize = 12
HeaderText.Font = Enum.Font.GothamBold
HeaderText.TextXAlignment = Enum.TextXAlignment.Left
HeaderText.Parent = MainFrame

-- TOMBOL MINIMIZE 
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "—"
CloseBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

-- ========================================================
-- NAVIGASI SIDEBAR (KIRI)
-- ========================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = Sidebar

local SidebarScroll = Instance.new("ScrollingFrame")
SidebarScroll.Size = UDim2.new(1, 0, 1, -40)
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 150)
SidebarScroll.ScrollBarThickness = 0
SidebarScroll.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.Parent = SidebarScroll

-- CONTENT PANEL (KANAN)
local ContentPanel = Instance.new("Frame")
ContentPanel.Size = UDim2.new(1, -140, 1, -45)
ContentPanel.Position = UDim2.new(0, 135, 0, 40)
ContentPanel.BackgroundTransparency = 1
ContentPanel.Parent = MainFrame

-- Tab 1: Player Mod
local TabMovement = Instance.new("ScrollingFrame")
TabMovement.Size = UDim2.new(1, 0, 1, 0)
TabMovement.BackgroundTransparency = 1
TabMovement.CanvasSize = UDim2.new(0, 0, 0, 250)
TabMovement.ScrollBarThickness = 2
TabMovement.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
TabMovement.Visible = true
TabMovement.Parent = ContentPanel

local TabMovementLayout = Instance.new("UIListLayout")
TabMovementLayout.Padding = UDim.new(0, 6)
TabMovementLayout.Parent = TabMovement

-- Tab 2: Teleport
local TabTeleport = Instance.new("ScrollingFrame")
TabTeleport.Size = UDim2.new(1, 0, 1, 0)
TabTeleport.BackgroundTransparency = 1
TabTeleport.CanvasSize = UDim2.new(0, 0, 0, 350)
TabTeleport.ScrollBarThickness = 2
TabTeleport.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
TabTeleport.Visible = false
TabTeleport.Parent = ContentPanel

local TabTeleportLayout = Instance.new("UIListLayout")
TabTeleportLayout.Padding = UDim.new(0, 5)
TabTeleportLayout.Parent = TabTeleport

-- MANAGEMENT TAB SWITCH
local function createTabButton(name, order, targetTab)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.Position = UDim2.new(0, 5, 0, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = "  " .. name
    Btn.TextColor3 = order == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 130, 130)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = SidebarScroll

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0, 14)
    Indicator.Position = UDim2.new(0, 2, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Indicator.Visible = order == 1
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        TabMovement.Visible = false
        TabTeleport.Visible = false
        for _, v in pairs(SidebarScroll:GetChildren()) do
            if v:IsA("TextButton") then
                v.TextColor3 = Color3.fromRGB(140, 130, 130)
                if v:FindFirstChild("Frame") then v.Frame.Visible = false end
            end
        end
        targetTab.Visible = true
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.Visible = true
    end)
end

createTabButton("🏃 Player Mod", 1, TabMovement)
createTabButton("🎯 Teleport", 2, TabTeleport)

-- PROFILE SECTION (KIRI BAWAH)
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1, 0, 0, 40)
ProfileFrame.Position = UDim2.new(0, 0, 1, -40)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
ProfileFrame.BorderSizePixel = 0
ProfileFrame.Parent = Sidebar

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 26, 0, 26)
AvatarImg.Position = UDim2.new(0, 8, 0.5, -13)
AvatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
AvatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png"
AvatarImg.Parent = ProfileFrame

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarImg

local ProfileName = Instance.new("TextLabel")
ProfileName.Size = UDim2.new(1, -42, 0, 14)
ProfileName.Position = UDim2.new(0, 38, 0.5, -12)
ProfileName.BackgroundTransparency = 1
ProfileName.Text = player.DisplayName
ProfileName.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfileName.TextSize = 10
ProfileName.Font = Enum.Font.GothamBold
ProfileName.TextXAlignment = Enum.TextXAlignment.Left
ProfileName.Parent = ProfileFrame

local ProfileUser = Instance.new("TextLabel")
ProfileUser.Size = UDim2.new(1, -42, 0, 10)
ProfileUser.Position = UDim2.new(0, 38, 0.5, 2)
ProfileUser.BackgroundTransparency = 1
ProfileUser.Text = "@" .. player.Name
ProfileUser.TextColor3 = Color3.fromRGB(120, 110, 110)
ProfileUser.TextSize = 8
ProfileUser.Font = Enum.Font.GothamSemibold
ProfileUser.TextXAlignment = Enum.TextXAlignment.Left
ProfileUser.Parent = ProfileFrame

-- ========================================================
-- FUNGSI TOGGLE SWITCH LITE
-- ========================================================
local function createLuxuryToggle(titleText, callback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, -6, 0, 38)
    RowFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    RowFrame.Parent = TabMovement

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 6)
    RowCorner.Parent = RowFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame

    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Size = UDim2.new(0, 36, 0, 18)
    SwitchBg.Position = UDim2.new(1, -44, 0.5, -9)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SwitchBg.Text = ""
    SwitchBg.Parent = RowFrame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBg

    local Ball = Instance.new("Frame")
    Ball.Size = UDim2.new(0, 12, 0, 12)
    Ball.Position = UDim2.new(0, 3, 0.5, -6)
    Ball.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Ball.Parent = SwitchBg

    local BallCorner = Instance.new("UICorner")
    BallCorner.CornerRadius = UDim.new(1, 0)
    BallCorner.Parent = Ball

    local active = false
    SwitchBg.MouseButton1Click:Connect(function()
        active = not active
        if active then
            SwitchBg.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
            Ball.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            Ball.Position = UDim2.new(1, -15, 0.5, -6)
        else
            SwitchBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            Ball.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            Ball.Position = UDim2.new(0, 3, 0.5, -6)
        end
        callback(active)
    end)
end

-- CORE NOCLIP SYSTEM
RunService.Stepped:Connect(function()
    if isBypassTpActive or flyEnabled then
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        end
        
