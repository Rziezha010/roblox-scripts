-- =========================================================
-- 🧠 DEV.GIGA FINAL ZENITH SYSTEM
-- 🌍 Emergent NPC Civilization Engine (ALL-IN-ONE)
-- ⚙️ STABLE | SCANNED | ROBLOX SAFE | NO OVERLOAD
-- =========================================================

local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local PathfindingService = game:GetService("PathfindingService")

-- =========================================================
-- 🌍 GLOBAL WORLD STATE (CIVILIZATION LAYER)
-- =========================================================
local World = {
	Tick = 0,

	Economy = 100,
	Peace = 70,
	War = 0,

	Event = "normal",

	Factions = {
		A = 50,
		B = 50
	}
}

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

	-- PERSONALITY CORE
	self.Mood = 100
	self.Emotion = "calm"
	self.Trait = ({"Friendly","Shy","Grumpy","Curious"})[math.random(1,4)]

	-- 🧬 DYNASTY (simplified safe version)
	self.Dynasty = {
		name = "Clan_" .. math.random(1000,9999),
		generation = 1,
		power = math.random(50,100)
	}

	-- 🧠 DNA
	self.DNA = {
		social = math.random(),
		curiosity = math.random(),
		stability = math.random()
	}

	-- 💾 MEMORY (LIMITED SAFE)
	self.Memory = {
		trust = 0,
		events = {}
	}

	-- ⏱ CONTROL
	self.LastChat = 0
	self.LastMove = 0

	self.Settings = {
		Vision = 50,
		ChatRange = 30,
		UpdateRate = 0.6,
		PathCooldown = 0.8,
		ChatCooldown = 3
	}

	return self
end

-- =========================================================
-- 🌍 WORLD SIMULATION (LIGHT TICK)
-- =========================================================
function NPC:WorldTick()

	World.Tick += 1

	if World.Tick % 20 == 0 then
		World.Economy += math.random(-2,3)
	end

	if World.Tick % 35 == 0 then
		local change = math.random(-5,5)
		World.Factions.A += change
		World.Factions.B -= change
	end

	if World.Tick % 60 == 0 then
		local events = {"normal","war","peace","famine","boom"}
		World.Event = events[math.random(1,#events)]
	end
end

-- =========================================================
-- ❤️ EMOTION SYSTEM (FSM)
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

	-- world influence
	if World.Event == "war" then
		self.Mood -= 0.4
	elseif World.Event == "peace" then
		self.Mood += 0.1
	end
end

-- =========================================================
-- 💬 CHAT SYSTEM (SAFE)
-- =========================================================
function NPC:Say(text)

	if os.clock() - self.LastChat < self.Settings.ChatCooldown then return end
	self.LastChat = os.clock()

	local emoji = ""
	if self.Emotion == "happy" then emoji = " 😊"
	elseif self.Emotion == "sad" then emoji = " 😢"
	elseif self.Emotion == "angry" then emoji = " 😠"
	end

	Chat:Chat(self.Head, text .. emoji, Enum.ChatColor.White)
end

-- =========================================================
-- 👤 PLAYER DETECTION
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
-- 🧠 DECISION ENGINE (FULL EMERGENT LOGIC)
-- =========================================================
function NPC:Think(player, dist)

	local score = {
		follow = 0,
		talk = 0,
		work = 0,
		idle = 5
	}

	-- vision
	if dist < self.Settings.Vision then
		score.follow += 5
	end

	if dist < self.Settings.ChatRange then
		score.talk += 10
	end

	-- DNA influence
	score.talk += self.DNA.social * 5
	score.follow += self.DNA.curiosity * 2

	-- trait influence
	if self.Trait == "Friendly" then
		score.talk += 3
	elseif self.Trait == "Shy" then
		score.talk -= 3
	elseif self.Trait == "Grumpy" then
		score.idle += 5
	end

	-- dynasty influence
	score.talk += self.Dynasty.power * 0.02

	-- world influence
	if World.Event == "war" then
		score.follow += 2
		score.idle += 2
	end

	-- emotion influence
	if self.Emotion == "angry" then
		score.idle += 10
	end

	-- PICK BEST ACTION
	local best = -math.huge
	local action = "idle"

	for k,v in pairs(score) do
		if v > best then
			best = v
			action = k
		end
	end

	return action
end

-- =========================================================
-- 🚶 MOVEMENT SYSTEM (SAFE PATHFINDING)
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
-- 🧠 MAIN LOOP (STABLE SIMULATION CORE)
-- =========================================================
function NPC:Start()

	while self.Humanoid.Health > 0 do

		task.wait(self.Settings.UpdateRate)

		self:WorldTick()
		self:UpdateEmotion()

		local player, dist = self:GetClosestPlayer()

		if player and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")

			if hrp then
				local action = self:Think(player, dist)

				if action == "follow" then
					self:Move(hrp.Position)

				elseif action == "talk" then
					self.Memory.trust += 1
					self:Say("Aku NPC di dunia yang hidup...")

				elseif action == "work" then
					self:Say("Aku sedang menjalani hidupku...")

				else
					self.Memory.trust -= 0.1
				end
			end
		else
			self.Mood = math.max(self.Mood - 0.1, 0)
		end

	end
end

return NPC