-- Fly Script (Roblox Luau)
-- Taruh di LocalScript: StarterPlayerScripts

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 60

local move = Vector3.new(0, 0, 0)
local bodyVelocity
local bodyGyro

-- respawn handler
player.CharacterAdded:Connect(function(char)
	character = char
	root = character:WaitForChild("HumanoidRootPart")
end)

-- toggle fly
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.F then
		flying = not flying

		if flying then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
			bodyVelocity.Parent = root

			bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
			bodyGyro.Parent = root
		else
			if bodyVelocity then bodyVelocity:Destroy() end
			if bodyGyro then bodyGyro:Destroy() end
		end
	end

	if input.KeyCode == Enum.KeyCode.W then move = Vector3.new(0, 0, -1) end
	if input.KeyCode == Enum.KeyCode.S then move = Vector3.new(0, 0, 1) end
	if input.KeyCode == Enum.KeyCode.A then move = Vector3.new(-1, 0, 0) end
	if input.KeyCode == Enum.KeyCode.D then move = Vector3.new(1, 0, 0) end
	if input.KeyCode == Enum.KeyCode.Space then move = Vector3.new(0, 1, 0) end
	if input.KeyCode == Enum.KeyCode.LeftControl then move = Vector3.new(0, -1, 0) end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W
	or input.KeyCode == Enum.KeyCode.S
	or input.KeyCode == Enum.KeyCode.A
	or input.KeyCode == Enum.KeyCode.D
	or input.KeyCode == Enum.KeyCode.Space
	or input.KeyCode == Enum.KeyCode.LeftControl then
		move = Vector3.new(0, 0, 0)
	end
end)

RunService.RenderStepped:Connect(function()
	if flying and root and bodyVelocity and bodyGyro then
		local cam = workspace.CurrentCamera

		bodyGyro.CFrame = cam.CFrame

		local direction = cam.CFrame:VectorToWorldSpace(move)
		bodyVelocity.Velocity = direction * speed
	end
end)
