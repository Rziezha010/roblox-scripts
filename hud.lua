-- ========================================================
-- RZIEZHA PREMIUM HUB V7 - SIDEBAR TABS EDITION (2026)
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
-- BASE GUI SYSTEM
-- ========================================================
local playerGui = player:WaitForChild("PlayerGui", 10)
if playerGui and playerGui:FindFirstChild("RziezhaHubGui") then
    playerGui.RziezhaHubGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RziezhaHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Tombol Open Kecil Minimalis Bulat
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0.02, 0, 0.2, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(20, 15, 15)
OpenButton.Text = "RZ"
OpenButton.TextColor3 = Color3.fromRGB(255, 50, 50)
OpenButton.TextSize = 15
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(255, 50, 50)
OpenStroke.Thickness = 1.5
OpenStroke.Parent = OpenButton

-- FRAME UTAMA MOD MENU (SIDEBAR DESIGN)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 260) -- Lebar disesuaikan agar muat 2 bagian
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 30, 30)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- TITLE BAR / HEADER ATAS
local HeaderText = Instance.new("TextLabel")
HeaderText.Size = UDim2.new(1, -60, 0, 35)
HeaderText.Position = UDim2.new(0, 15, 0, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.Text = "RziezhaHub" .. "  <font color='#ff3232'>Games : Universal Script</font>"
HeaderText.RichText = true
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.TextSize = 13
HeaderText.Font = Enum.Font.GothamBold
HeaderText.TextXAlignment = Enum.TextXAlignment.Left
HeaderText.Parent = MainFrame

-- TOMBOL MINIMIZE / CLOSE MERAH DI POJOK
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "—"
CloseBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.TextSize = 14
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
-- BAGIAN 1: SIDEBAR NAVIGASI (KIRI)
-- ========================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- UI Corner kiri bawah agar melengkung rapi mengikuti MainFrame
local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Sidebar

-- Penghalang pojok atas kanan sidebar agar tidak ikut melengkung di dalam frame
local AntiClip = Instance.new("Frame")
AntiClip.Size = UDim2.new(0, 20, 0, 20)
AntiClip.Position = UDim2.new(1, -20, 0, 0)
AntiClip.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
AntiClip.BorderSizePixel = 0
AntiClip.Parent = Sidebar

local SidebarScroll = Instance.new("ScrollingFrame")
SidebarScroll.Size = UDim2.new(1, 0, 1, -50) -- Sisakan ruang untuk profil bawah
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 200)
SidebarScroll.ScrollBarThickness = 0
SidebarScroll.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = SidebarScroll

-- ========================================================
-- BAGIAN 2: CONTENT AREA PANEL (KANAN)
-- ========================================================
local ContentPanel = Instance.new("Frame")
ContentPanel.Size = UDim2.new(1, -160, 1, -45)
ContentPanel.Position = UDim2.new(0, 155, 0, 40)
ContentPanel.BackgroundTransparency = 1
ContentPanel.Parent = MainFrame

-- Tab 1: Fitur Utama (Player/Movement)
local TabMovement = Instance.new("ScrollingFrame")
TabMovement.Size = UDim2.new(1, 0, 1, 0)
TabMovement.BackgroundTransparency = 1
TabMovement.CanvasSize = UDim2.new(0, 0, 0, 300)
TabMovement.ScrollBarThickness = 2
TabMovement.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
TabMovement.Visible = true
TabMovement.Parent = ContentPanel

local TabMovementLayout = Instance.new("UIListLayout")
TabMovementLayout.Padding = UDim.new(0, 8)
TabMovementLayout.Parent = TabMovement

-- Tab 2: Teleport Player List
local TabTeleport = Instance.new("ScrollingFrame")
TabTeleport.Size = UDim2.new(1, 0, 1, 0)
TabTeleport.BackgroundTransparency = 1
TabTeleport.CanvasSize = UDim2.new(0, 0, 0, 400)
TabTeleport.ScrollBarThickness = 2
TabTeleport.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
TabTeleport.Visible = false
TabTeleport.Parent = ContentPanel

local TabTeleportLayout = Instance.new("UIListLayout")
TabTeleportLayout.Padding = UDim.new(0, 6)
TabTeleportLayout.Parent = TabTeleport

-- ========================================================
-- SISTEM INTERAKSI NAVIGASI TAB SIDEBAR
-- ========================================================
local function createTabButton(name, order, targetTab)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 32)
    Btn.Position = UDim2.new(0, 5, 0, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = "   " .. name
    Btn.TextColor3 = order == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 140, 140)
    Btn.TextSize = 12
    Btn.Font = order == 1 and Enum.Font.GothamBold or Enum.Font.GothamSemibold
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = order
    Btn.Parent = SidebarScroll

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0, 16)
    Indicator.Position = UDim2.new(0, 2, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Indicator.Visible = order == 1
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        -- Reset Semua Tab & Tombol
        TabMovement.Visible = false
        TabTeleport.Visible = false
        
        for _, v in pairs(SidebarScroll:GetChildren()) do
            if v:IsA("TextButton") then
                v.TextColor3 = Color3.fromRGB(150, 140, 140)
                v.Font = Enum.Font.GothamSemibold
                if v:FindFirstChild("Frame") then v.Frame.Visible = false end
            end
        end
        
        -- Aktifkan Tab yang dipilih
        targetTab.Visible = true
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Indicator.Visible = true
    end)
end

createTabButton("🏃 Player Mod", 1, TabMovement)
createTabButton("🎯 Teleport", 2, TabTeleport)

-- ========================================================
-- TEMPAT PROFIL SPERTI DI SCREENSHOT (KIRI BAWAH)
-- ========================================================
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1, 0, 0, 45)
ProfileFrame.Position = UDim2.new(0, 0, 1, -45)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
ProfileFrame.BorderSizePixel = 0
ProfileFrame.Parent = Sidebar

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 32, 0, 32)
AvatarImg.Position = UDim2.new(0, 10, 0.5, -16)
AvatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
-- Mengambil otomatis foto avatar asli akun Roblox kamu (Ace)
AvatarImg.Image = "
