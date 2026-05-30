-- ========================================================
-- RZIEZHA PREMIUM HUB V7.1 - BUG-FREE & STABLE EDITION (2026)
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
-- BASE GUI SYSTEM (ANTI-LAG & CLEANUP)
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
MainFrame.Size = UDim2.new(0, 480, 0, 260)
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

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Sidebar

local AntiClip = Instance.new("Frame")
AntiClip.Size = UDim2.new(0, 20, 0, 20)
AntiClip.Position = UDim2.new(1, -20, 0, 0)
AntiClip.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
AntiClip.BorderSizePixel = 0
AntiClip.Parent = Sidebar

local SidebarScroll = Instance.new("ScrollingFrame")
SidebarScroll.Size = UDim2.new(1, 0, 1, -50)
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

-- SISTEM INTERAKSI NAVIGASI TAB SIDEBAR
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
        TabMovement.Visible = false
        TabTeleport.Visible = false
        
        for _, v in pairs(SidebarScroll:GetChildren()) do
            if v:IsA("TextButton") then
                v.TextColor3 = Color3.fromRGB(150, 140, 140)
                v.Font = Enum.Font.GothamSemibold
                if v:FindFirstChild("Frame") then v.Frame.Visible = false end
            end
        end
        
        targetTab.Visible = true
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Indicator.Visible = true
    end)
end

createTabButton("🏃 Player Mod", 1, TabMovement)
createTabButton("🎯 Teleport", 2, TabTeleport)

-- PROFILE SECTION (KIRI BAWAH)
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
AvatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
AvatarImg.Parent = ProfileFrame

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarImg

local ProfileName = Instance.new("TextLabel")
ProfileName.Size = UDim2.new(1, -50, 0, 16)
ProfileName.Position = UDim2.new(0, 48, 0.5, -14)
ProfileName.BackgroundTransparency = 1
ProfileName.Text = player.DisplayName
ProfileName.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfileName.TextSize = 11
ProfileName.Font = Enum.Font.GothamBold
ProfileName.TextXAlignment = Enum.TextXAlignment.Left
ProfileName.Parent = ProfileFrame

local ProfileUser = Instance.new("TextLabel")
ProfileUser.Size = UDim2.new(1, -50, 0, 12)
ProfileUser.Position = UDim2.new(0, 48, 0.5, 2)
ProfileUser.BackgroundTransparency = 1
ProfileUser.Text = "@" .. player.Name
ProfileUser.TextColor3 = Color3.fromRGB(130, 120, 120)
ProfileUser.TextSize = 9
ProfileUser.Font = Enum.Font.GothamSemibold
ProfileUser.TextXAlignment = Enum.TextXAlignment.Left
ProfileUser.Parent = ProfileFrame

-- FUNGSI MEMBUAT TOGGLE SWITCH
local function createLuxuryToggle(titleText, callback)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, -8, 0, 44)
    RowFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    RowFrame.Parent = TabMovement

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 8)
    RowCorner.Parent = RowFrame
    
    local RowStroke = Instance.new("UIStroke")
    RowStroke.Color = Color3.fromRGB(30, 28, 28)
    RowStroke.Parent = RowFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame

    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Size = UDim2.new(0, 40, 0, 20)
    SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SwitchBg.Text = ""
    SwitchBg.Parent = RowFrame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBg

    local Ball = Instance.new("Frame")
    Ball.Size = UDim2.new(0, 14, 0, 14)
    Ball.Position = UDim2.new(0, 3, 0.5, -7)
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
            Ball.Position = UDim2.new(1, -17, 0.5, -7)
        else
            SwitchBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            Ball.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            Ball.Position = UDim2.new(0, 3, 0.5, -7)
        end
        callback(active)
    end)
end

-- STABLE NOCLIP INJECTION
RunService.Stepped:Connect(function()
    if isBypassTpActive or flyEnabled then
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

createLuxuryToggle("🚀 Ultimate Fly Hack", function(state)
    flyEnabled = state
    local char = player.Character
    if flyEnabled then
        if flyConnection then flyConnection:Disconnect() end
        local root = char and char:WaitForChild("HumanoidRootPart", 10)
        if root then
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

            flyConnection = RunService.RenderStepped:Connect(function()
                if root and bV and bG then
                    bG.CFrame = camera.CFrame
                    bV.Velocity = camera.CFrame.LookVector * flySpeed
                end
            end)
        end
    else
        if flyConnection then flyConnection:Disconnect() end
        if char and char:FindFirstChild("HumanoidRootPart") then
            if char.HumanoidRootPart:FindFirstChild("FlyVelocity") then char.HumanoidRootPart.FlyVelocity:Destroy() end
            if char.HumanoidRootPart:FindFirstChild("FlyGyro") then char.HumanoidRootPart.FlyGyro:Destroy() end
        end
    end
end)

createLuxuryToggle("⛰️ Auto Mountain Walk", function(state)
    walkEnabled = state
    if walkEnabled then
        if walkConnection then walkConnection:Disconnect() end
        walkConnection = RunService.RenderStepped:Connect(function()
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
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
        if walkConnection then walkConnection:Disconnect() end
    end
end)

createLuxuryToggle("⚡ Touch Screen TP", function(state)
    tpClickEnabled = state
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not tpClickEnabled or isBypassTpActive then return end
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
-- BUG-FREE STREAMINGENABLED TELEPORT LOGIC (TAB 2)
-- ========================================================
local function bypassStreamingTp(targetPlayer)
    -- Sistem Keamanan 1: Mencegah Spam Klik jika proses terbang sedang aktif
    if isBypassTpActive then return end
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not root or not hum or hum.Health <= 0 then return end
    
    -- Memastikan model karakter target ada di server dunia
    local tChar = targetPlayer.Character
    if not tChar or not tChar.PrimaryPart then return end
    
    isBypassTpActive = true
    
    -- Membuat gaya penahan gravitasi stabil agar tidak amblas atau terlempar kencang
    local bf = Instance.new("BodyForce")
    bf.Force = Vector3.new(0, workspace.Gravity * root:GetMass(), 0)
    bf.Parent = root
    
    local bypassConnection
    bypassConnection = RunService.Heartbeat:Connect(function()
        -- Sistem Keamanan 2: Validasi Real-time jika target tiba-tiba hilang atau mati
        local currentTChar = targetPlayer.Character
        local tPart = currentTChar and currentTChar:FindFirstChild("HumanoidRootPart") or (currentTChar and currentTChar.PrimaryPart)
        
        if tPart and root and hum and hum.Health > 0 then
            local targetPos = tPart.Position + Vector3.new(0, 4, 0)
            local myPos = root.Position
            local distance = (targetPos - myPos).Magnitude
            
            -- Jika sudah sampai dekat target, bersihkan koneksi agar kembali normal
            if distance < 12 then
                if bypassConnection then bypassConnection:Disconnect() end
                bf:Destroy()
                root.Velocity = Vector3.new(0,0,0) -- Amankan momentum biar tidak kepeleset
                isBypassTpActive = false
                return
            end
            
            -- Kecepatan luncuran ditingkatkan menjadi 420 (Sangat kilat & bypass lancar)
            root.Velocity = (targetPos - myPos).Unit * 420
            
            -- Memperbaiki rotasi agar pergerakan tidak kaku (menghindari deteksi kaku anticheat)
            root.CFrame = CFrame.new(myPos, Vector3.new(targetPos.X, myPos.Y, targetPos.Z))
        else
            -- Jika target mati di tengah jalan, langsung hentikan proses agar kamu tidak terlempar ke langit void
            if bypassConnection then bypassConnection:Disconnect() end
            bf:Destroy()
            root.Velocity = Vector3.new(0,0,0)
            isBypassTpActive = false
        end
    end)
end

local function updatePlayerList()
    for _, child in pairs(TabTeleport:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local currentOrder = 1
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local PlrBtn = Instance.new("TextButton")
            PlrBtn.Size = UDim2.new(1, -8, 0, 34)
            PlrBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            PlrBtn.Text = "   🎯   " .. p.DisplayName .. " (@" .. p.Name .. ")"
            PlrBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
            PlrBtn.TextSize = 11
            PlrBtn.Font = Enum.Font.GothamSemibold
            PlrBtn.TextXAlignment = Enum.TextXAlignment.Left
            PlrBtn.Parent = TabTeleport
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = PlrBtn
            
            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Color3.fromRGB(32, 28, 28)
            BtnStroke.Parent = PlrBtn

            PlrBtn.MouseButton1Click:Connect(function()
                bypassStreamingTp(p)
            end)

            currentOrder = currentOrder + 1
        end
    end
    TabTeleport.CanvasSize = UDim2.new(0, 0, 0, currentOrder * 40)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()
