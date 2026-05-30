-- FLY SCRIPT MOBILE EDITION (MAXIMIZED & ANTI-ERROR)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- Konfigurasi
local flying = true -- Otomatis langsung terbang saat dieksekusi
local speed = 70    -- Kecepatan terbang

-- Bersihkan attachment lama jika ada
if root:FindFirstChild("FlyAttachment") then root.FlyAttachment:Destroy() end
if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end

-- Membuat sistem penggerak baru (LinearVelocity & AlignOrientation)
local attachment = Instance.new("Attachment")
attachment.Name = "FlyAttachment"
attachment.Parent = root

local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.Name = "FlyVelocity"
linearVelocity.MaxForce = 9e9
linearVelocity.Attachment0 = attachment
linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
linearVelocity.Parent = root

local alignOrient = Instance.new("AlignOrientation")
alignOrient.Name = "FlyGyro"
alignOrient.MaxTorque = 9e9
alignOrient.Responsiveness = 200
alignOrient.Attachment0 = attachment
alignOrient.Mode = Enum.OrientationMode.OneAttachment
alignOrient.Parent = root

-- Respawn Handler agar tidak macet saat karakter mati
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5) -- Beri jeda sedikit agar karakter selesai loading
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    if flying and root then
        attachment.Parent = root
        linearVelocity.Parent = root
        alignOrient.Parent = root
    end
end)

-- Loop Utama (RenderStepped) - Super Aman & Ringan
local flyConnection
flyConnection = RunService.RenderStepped:Connect(function()
    if not flying then 
        linearVelocity.VectorVelocity = Vector3.new(0,0,0)
        return 
    end
    
    -- Cek keamanan jika part karakter mendadak hilang
    if not root or not root.Parent or not humanoid then return end
    
    -- Mengunci rotasi karakter agar mengikuti kamera HP
    alignOrient.CFrame = camera.CFrame
    
    -- Logika Pergerakan Mobile (Mengikuti Analog & Kamera)
    local moveDirection = humanoid.MoveDirection
    
    if moveDirection.Magnitude > 0 then
        -- Jika analog HP digerakkan, karakter terbang sesuai arah analog + kamera
        local targetVelocity = camera.CFrame:VectorToWorldSpace(Vector3.new(
            moveDirection.X, 
            camera.CFrame.LookVector.Y * (moveDirection.Z < 0 and 1 or -1), 
            moveDirection.Z
        ))
        linearVelocity.VectorVelocity = targetVelocity.Unit * speed
    else
        -- Jika diam, karakter melayang konstan di tempat (tidak jatuh)
        linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
    end
    
    -- Fitur Tambahan: Tahan tombol lompat untuk naik ke atas secara instan
    if UIS:IsKeyDown(Enum.KeyCode.Space) or (UIS.TouchEnabled and humanoid.Jump) then
        linearVelocity.VectorVelocity = Vector3.new(0, speed, 0)
    end
end)
