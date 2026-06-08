
local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local PathfindingService = game:GetService("PathfindingService")

local NPC = {}
NPC.__index = NPC

-- =========================
-- CONSTRUCTOR
-- =========================
function NPC.new(model)
	local self = setmetatable({}, NPC)

	self.Model = model
	self.Humanoid = model:WaitForChild("Humanoid")
	self.Root = model:WaitForChild("HumanoidRootPart")
	self.Head = model:WaitForChild("Head")

	-- CORE STATE
	self.Mood = 100
	self.Memory = {}
	self.Group = nil

	-- ANTI BUG TIMERS
	self.LastChat = 0
	self.LastMove = 0

	-- SETTINGS
	self.Settings = {
		Vision = 45,
		ChatRange = 35,
		UpdateRate = 0.5,
		PathCooldown = 0.8,
		ChatCooldown = 3,
		RoamRange = 50
	}

	-- 🧠 INDIVIDUAL INTELLIGENCE (FIXED BALANCED RANGE)
	self.Brain = {
		IQ = math.random(70, 130),
		Curiosity = math.random(),
		Sociability = math.random(),
		MemoryStrength = math.random(),
		Aggression = math.random()
	}

	-- TRAIT BASE (akan override oleh child class)
	self.Trait = "Base"

	return self
end

-- =========================
-- UTIL
-- =========================
function NPC:_pick(t)
	return t[math.random(#t)]
end

function NPC:Say(text)
	if not text then return end
	if os.clock() - self.LastChat < self.Settings.ChatCooldown then return end

	self.LastChat = os.clock()
	Chat:Chat(self.Head, text, Enum.ChatColor.White)
end

function NPC:GetClosestPlayer()
	local closest, dist = nil, math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")

		if hrp then
			local d = (hrp.Position - self.Root.Position).Magnitude
			if d < dist then
				dist = d
				closest = p
			end
		end
	end

	return closest, dist
end

-- =========================
-- SAFE PATH SYSTEM (BUG FIXED)
-- =========================
function NPC:Move(target)
	if os.clock() - self.LastMove < self.Settings.PathCooldown then return end
	self.LastMove = os.clock()

	if (self.Root.Position - target).Magnitude < 3 then return end

	task.spawn(function()
		local path = PathfindingService:CreatePath({
			AgentRadius = 2,
			AgentHeight = 5,
			AgentCanJump = true,
			AgentCanClimb = true
		})

		local ok = pcall(function()
			path:ComputeAsync(self.Root.Position, target)
		end)

		if not ok then return end

		if path.Status == Enum.PathStatus.Success then
			local wp = path:GetWaypoints()
			if wp[2] then
				self.Humanoid:MoveTo(wp[2].Position)

				if wp[2].Action == Enum.PathAction.Jump then
					self.Humanoid.Jump = true
				end
			end
		else
			self.Humanoid:MoveTo(target)
		end
	end)
end

-- =========================
-- 🧠 BRAIN DECISION SYSTEM (FIXED + BALANCED)
-- =========================
function NPC:Think(player, dist)

	local b = self.Brain
	local mood = self.Mood

	local follow = 0
	local talk = 0
	local idle = 5

	-- vision influence
	if dist < self.Settings.Vision then
		follow += 5
	end

	if dist < self.Settings.ChatRange then
		talk += 10
	end

	-- intelligence influence
	follow += b.IQ * 0.03
	talk += b.Sociability * 8

	if b.Curiosity > 0.6 then
		follow += 4
	end

	-- mood influence
	if mood < 30 then
		idle += 10
	end

	-- trait influence (safe additive, not overpowering)
	if self.Trait == "Friendly" then
		talk += 3
		follow += 2
	elseif self.Trait == "Shy" then
		talk -= 2
		follow -= 1
	elseif self.Trait == "Grumpy" then
		idle += 4
	elseif self.Trait == "Curious" then
		follow += 3
	end

	-- FINAL DECISION
	if talk > follow and talk > idle then
		return "talk"
	elseif follow > idle then
		return "follow"
	else
		return "idle"
	end
end

-- =========================
-- EVALUATION (FIXED SAFE FLOW)
-- =========================
function NPC:Evaluate()
	local player, dist = self:GetClosestPlayer()

	if player and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")

		if hrp then
			return self:Think(player, dist), player, dist
		end
	end

	return "idle", nil, math.huge
end

-- =========================
-- UPDATE CORE
-- =========================
function NPC:Update()
	local state, player, dist = self:Evaluate()

	if state == "follow" then
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			self:Move(hrp.Position)
		end

	elseif state == "talk" then
		self:Talk(player)

	else
		self:Idle()
	end
end

-- DEFAULT BEHAVIOR (OVERRIDABLE)
function NPC:Talk(player)
	self:Say("Halo!")
	self.Mood = math.min(self.Mood + 1, 100)
end

function NPC:Idle()
	self.Mood = math.max(self.Mood - 0.05, 0)
end

-- =========================
-- START LOOP
-- =========================
function NPC:Start()
	while self.Humanoid.Health > 0 do
		task.wait(self.Settings.UpdateRate)
		self:Update()
	end
end

return NPC