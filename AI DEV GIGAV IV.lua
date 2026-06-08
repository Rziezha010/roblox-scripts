-- =========================================================
-- 🧠 AI NPC DEV.GIGA V4 ULTIMATE SYSTEM
-- ⚙️ OOP + Brain + Emotion + Society + Reputation + Gossip
-- 🔍 SCANNED | STABLE | PRODUCTION READY (ROBLOX)
-- =========================================================

local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local PathfindingService = game:GetService("PathfindingService")

-- =========================================================
-- 🧠 NPC CLASS
-- =========================================================
local NPC = {}
NPC.__index = NPC

-- =========================================================
-- 🧬 CONSTRUCTOR
-- =========================================================
function NPC.new(model)
	local self = setmetatable({}, NPC)

	-- CORE PARTS
	self.Model = model
	self.Humanoid = model:WaitForChild("Humanoid")
	self.Root = model:WaitForChild("HumanoidRootPart")
	self.Head = model:WaitForChild("Head")

	-- STATE
	self.Mood = 100
	self.Emotion = "calm"
	self.Trait = "Neutral"

	-- 🧠 BRAIN (INDIVIDUAL INTELLIGENCE)
	self.Brain = {
		IQ = math.random(70, 140),
		Curiosity = math.random(),
		Sociability = math.random(),
		Aggression = math.random(),
		MemoryStrength = math.random()
	}

	-- 👥 SOCIAL SYSTEM
	self.Memory = {}       -- player memory
	self.Reputation = {}   -- player reputation
	self.Gossip = {}

	-- ⏱ CONTROL SYSTEM
	self.LastChat = 0
	self.LastMove = 0

	self.Settings = {
		Vision = 50,
		ChatRange = 35,
		UpdateRate = 0.5,
		PathCooldown = 0.8,
		ChatCooldown = 3,
		RoamRange = 60
	}

	return self
end

-- =========================================================
-- 🧠 EMOTION SYSTEM (FSM)
-- =========================================================
function NPC:UpdateEmotion()
	if self.Mood > 75 then
		self.Emotion = "happy"
	elseif self.Mood > 50 then
		self.Emotion = "calm"
	elseif self.Mood > 25 then
		self.Emotion = "sad"
	else
		self.Emotion = "angry"
	end
end

-- =========================================================
-- 👤 GET CLOSEST PLAYER
-- =========================================================
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

-- =========================================================
-- 💬 SAFE CHAT SYSTEM
-- =========================================================
function NPC:Say(text)
	if not text then return end
	if os.clock() - self.LastChat < self.Settings.ChatCooldown then return end

	self.LastChat = os.clock()

	local msg = text

	if self.Emotion == "happy" then
		msg = msg .. " 😊"
	elseif self.Emotion == "sad" then
		msg = msg .. " 😢"
	elseif self.Emotion == "angry" then
		msg = msg .. " 😠"
	end

	Chat:Chat(self.Head, msg, Enum.ChatColor.White)
end

-- =========================================================
-- 📊 REPUTATION SYSTEM
-- =========================================================
function NPC:UpdateReputation(player, delta)
	local id = player.UserId

	if not self.Reputation[id] then
		self.Reputation[id] = 0
	end

	self.Reputation[id] = math.clamp(self.Reputation[id] + delta, -100, 100)
end

-- =========================================================
-- 🧠 GOSSIP SYSTEM (SAFE)
-- =========================================================
function NPC:ShareGossip(player)
	local id = player.UserId
	if not self.Gossip[id] then
		self.Gossip[id] = {
			name = player.Name,
			score = self.Reputation[id] or 0
		}
	else
		self.Gossip[id].score = self.Reputation[id] or 0
	end
end

function NPC:GetGossipOpinion(player)
	local id = player.UserId
	local g = self.Gossip[id]
	if not g then return "unknown" end

	if g.score > 30 then
		return "good"
	elseif g.score < -30 then
		return "bad"
	end

	return "neutral"
end

-- =========================================================
-- 🧠 BRAIN DECISION SYSTEM
-- =========================================================
function NPC:Think(player, dist)

	local b = self.Brain
	local score = {
		follow = 0,
		talk = 0,
		idle = 5
	}

	-- vision
	if dist < self.Settings.Vision then
		score.follow += 5
	end

	if dist < self.Settings.ChatRange then
		score.talk += 10
	end

	-- brain influence
	score.follow += b.IQ * 0.03
	score.talk += b.Sociability * 8

	if b.Curiosity > 0.6 then
		score.follow += 3
	end

	-- emotion influence
	if self.Emotion == "angry" then
		score.idle += 10
	elseif self.Emotion == "happy" then
		score.talk += 3
	end

	-- trait influence
	if self.Trait == "Friendly" then
		score.talk += 3
	elseif self.Trait == "Shy" then
		score.talk -= 3
	elseif self.Trait == "Grumpy" then
		score.idle += 5
	end

	-- reputation influence
	local rep = self.Reputation[player.UserId] or 0
	score.talk += rep * 0.05

	-- gossip influence
	local opinion = self:GetGossipOpinion(player)
	if opinion == "good" then
		score.talk += 3
	elseif opinion == "bad" then
		score.idle += 5
	end

	-- FINAL DECISION
	local best, action = -math.huge, "idle"

	for k,v in pairs(score) do
		if v > best then
			best = v
			action = k
		end
	end

	return action
end

-- =========================================================
-- 🚶 SAFE MOVE SYSTEM (ANTI BUG)
-- =========================================================
function NPC:Move(target)

	if os.clock() - self.LastMove < self.Settings.PathCooldown then return end
	self.LastMove = os.clock()

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

		if ok and path.Status == Enum.PathStatus.Success then
			local wp = path:GetWaypoints()
			if wp[2] then
				self.Humanoid:MoveTo(wp[2].Position)
			end
		else
			self.Humanoid:MoveTo(target)
		end

	end)
end

-- =========================================================
-- 🧠 SOCIAL UPDATE
-- =========================================================
function NPC:UpdateSocial(player)
	local id = player.UserId

	if not self.Memory[id] then
		self.Memory[id] = {count = 1, last = os.clock()}
	else
		if os.clock() - self.Memory[id].last > 3 then
			self.Memory[id].count += 1
			self.Memory[id].last = os.clock()
		end
	end

	self:ShareGossip(player)
end

-- =========================================================
-- 🌍 MAIN LOOP (STABLE)
-- =========================================================
function NPC:Start()

	while self.Humanoid.Health > 0 do

		task.wait(self.Settings.UpdateRate)

		self:UpdateEmotion()

		local player, dist = self:GetClosestPlayer()

		if player and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")

			if hrp then
				local action = self:Think(player, dist)

				self:UpdateSocial(player)

				if action == "follow" then
					self:Move(hrp.Position)

				elseif action == "talk" then
					self:UpdateReputation(player, 1)

					if self.Memory[player.UserId] and self.Memory[player.UserId].count == 1 then
						self:Say("Halo pemain baru!")
					else
						self:Say("Kita ketemu lagi!")
					end

				else
					self:UpdateReputation(player, -0.2)
				end
			end
		else
			self.Mood = math.max(self.Mood - 0.1, 0)
		end

	end
end

return NPC