-- ========================================================
-- RZIEZHA PREMIUM HUB V4 - INFINITE INSTANT TP (MOBILE)
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
local isTpProcessing = false
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
MainFrame.Size = UDim2.new(0, 280, 0, 240)
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
Header.Text = "RZIEZHA PREMIUM HUB V4"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize = 15
Header.Font = Enum.Font.SourceSansBold
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = MainFrame

-- TOMBOL MINIMIZE
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size =
