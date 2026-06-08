-- =========================================================
-- 🧠 DEV.GIGA Ω+ SELF EVOLVING CIVILIZATION ENGINE
-- 🌍 FINAL MASTER BUILD (ALL SYSTEM MERGED)
-- ⚙️ STABLE | SCANNED | ROBLOX SAFE LIMIT
-- =========================================================

local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local PathfindingService = game:GetService("PathfindingService")

-- =========================================================
-- 🌍 WORLD CORE (SELF EVOLVING LAYER)
-- =========================================================
local World = {
	Tick = 0,

	Economy = 100,
	Chaos = 0,
	Stability = 70,

	Event = "normal",

	Factions = {Order = 50, Chaos = 50},

	-- SELF EVOLUTION VARIABLES
	EvolutionRate = 0,
	HistoricalPressure = 0
}

-- =========================================================
-- 🧠 NPC CLASS
-- =========================================================
local NPC = {}
NPC.__index = NPC

-- =========================================================
-- 🧬 CREATE NPC
-- =========================================================
function NPC.new(model)

	local self = setmetatable({}, NPC)

	self.Model = model
	self.Humanoid = model:WaitForChild("Humanoid")
	self.Root = model:WaitForChild("HumanoidRootPart")
	self.Head = model:WaitForChild("Head")

	-- CORE LIFE
	self.Mood = 100
	self.Emotion = "calm"
	self.Trait = ({"Friendly","Shy","Grumpy","Curious","Logical"})[math.random(1,5)]

	-- 🧬 DNA (PERSONALITY CORE)
	self.DNA = {
		social = math.random(),
		intelligence = math.random(),
		adaptation = math.random()
	}

	-- 🧬 DYNASTY (SELF EVOLUTION CORE)
	self.Dynasty = {
		name = "Dyn_" .. math.random(1000,9999),
		generation = 1,
		influence = math.random(40,100),
		evolution = 1
	}

	-- 💰 LIFE SYSTEM
	self.Job = ({"Farmer","Guard","Trader","Hunter","Worker"})[math.random(1,5)]
	self.Money = math.random(20,80)

	-- 🧠 MEMORY SYSTEM
	self.Memory = {
		trust = 0,
		adaptationLevel = 0
	}

	-- ⏱ CONTROL
	self.LastChat = 0
	self.LastMove = 0

	self.Settings = {
		Vision = 60,
		ChatRange = 25,
		UpdateRate = 0.5,
		PathCooldown = 0.7,
		ChatCooldown = 2.5
	}

	return self
end

-- =========================================================
-- 🌍 WORLD EVOLUTION SYSTEM (SELF EVOLVE CORE)
-- =========================================================
function NPC:WorldTick()

	World.Tick += 1

	-- economy drift
	if World.Tick % 15 == 0 then
		World.Economy += math.random(-3,3)
	end

	-- faction drift
	if World.Tick % 25 == 0 then
		local change = math.random(-5,5)
		World.Factions.Order += change
		World.Factions.Chaos -= change
	end

	-- EVENT GENERATION (WORLD AUTONOMY)
	if World.Tick % 60 == 0 then
		local events = {"normal","war","peace","famine","boom","rebellion"}
		World.Event = events[math.random(1,#events)]
	end

	-- SELF EVOLUTION LOGIC (IMPORTANT)
	if World.Economy < 40 then
		World.EvolutionRate += 1
	end

	if World.Event == "war" then
		World.HistoricalPressure += 1
	end

	-- WORLD ADAPTS OVER TIME
	if World.HistoricalPressure > 50 then
		World.Stability -= 1
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

	-- WORLD INFLUENCE
	if World.Event == "war" then
		self.Mood -= 0.3
	elseif World.Event == "peace" then
		self.Mood += 0.1
	end
end

-- =========================================================
-- 🧠 SELF EVOLUTION SYSTEM (KEY FEATURE)
-- =========================================================
function NPC:SelfEvolve()

	-- adaptation grows over time
	self.Memory.adaptationLevel += self.DNA.adaptation * 0.01

	-- dynasty evolves
	if math.random() < 0.001 then
		self.Dynasty.generation += 1
		self.Dynasty.influence += math.random(1,5)
	end

	-- personality drift (emergent behavior)
	if self.Memory.adaptationLevel > 10 then
		if math.random() < 0.02 then
			self.Trait = ({"Friendly","Shy","Grumpy","Curious","Logical"})[math.random(1,5)]
		end
	end

	-- economy influence
	if self.Job == "Trader" and World.Economy > 120 then
		self.Money += 1
	end
end

-- =========================================================
-- 💬 CHAT SYSTEM
-- =========================================================
function NPC:Say(text)

	if os.clock() - self.LastChat < self.Settings.ChatCooldown then return end
	self.LastChat = os.clock()

	local emoji = ({
		happy = " 😊",
		calm = " 😌",
		sad = " 😢",
		angry = " 😠"
	})[self.Emotion] or ""

	Chat:Chat(self.Head, text .. emoji, Enum.ChatColor.White)
end

-- =========================================================
-- 👤 PLAYER DETECTION
-- =========================================================
function NPC:GetClosestPlayer()

	local best, dist = nil, math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")

		if hrp then
			local d = (hrp.Position - self.Root.Position).Magnitude
			if d < dist then
				dist = d
				best = p
			end
		end
	end

	return best, dist
end

-- =========================================================
-- 🧠 DECISION ENGINE (FULL EMERGENT AI)
-- =========================================================
function NPC:Think(player, dist)

	local score = {
		follow = 0,
		talk = 0,
		work = 0,
		trade = 0,
		idle = 5
	}

	if dist < self.Settings.Vision then
		score.follow += 5
	end

	if dist < self.Settings.ChatRange then
		score.talk += 10
	end

	score.talk += self.DNA.social * 5
	score.follow += self.DNA.intelligence * 3

	if self.Trait == "Friendly" then
		score.talk += 4
	elseif self.Trait == "Grumpy" then
		score.idle += 6
	elseif self.Trait == "Logical" then
		score.work += 5
	end

	if self.Job == "Trader" then
		score.trade += 6
	elseif self.Job == "Guard" then
		score.follow += 4
	end

	if World.Event == "war" then
		score.follow += 2
		score.idle += 2
	end

	score.talk += self.Dynasty.influence * 0.02

	if self.Emotion == "angry" then
		score.idle += 10
	end

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
-- 🚶 MOVEMENT SYSTEM
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
-- 🧠 MAIN LOOP (FULL SELF EVOLUTION SIMULATION)
-- =========================================================
function NPC:Start()

	while self.Humanoid.Health > 0 do

		task.wait(self.Settings.UpdateRate)

		self:WorldTick()
		self:UpdateEmotion()
		self:SelfEvolve()

		local player, dist = self:GetClosestPlayer()

		if player and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")

			if hrp then
				local action = self:Think(player, dist)

				if action == "follow" then
					self:Move(hrp.Position)

				elseif action == "talk" then
					self.Memory.trust += 1
					self:Say("Aku terus berevolusi di dunia ini...")

				elseif action == "trade" then
					self.Money += 1
					self:Say("Ekonomi dunia bergerak...")

				elseif action == "work" then
					self:Say(self.Job .. " sedang bekerja...")

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