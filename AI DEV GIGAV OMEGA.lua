-- =========================================================
-- 🧠 DEV.GIGA Ω+ v2.0 (STABLE EVOLUTION + SCAN OPTIMIZED)
-- =========================================================

local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local PathfindingService = game:GetService("PathfindingService")

-- =========================================================
-- 🌍 WORLD CORE (GLOBAL SIMULATION ENGINE)
-- =========================================================
local World = {
	Tick = 0,

	Economy = 100,
	Chaos = 0,
	Stability = 70,

	Event = "normal",

	Factions = {Order = 50, Chaos = 50},

	EvolutionRate = 0,
	HistoricalPressure = 0,

	-- 🧠 NEW: SAFE INFLUENCE QUEUE (ANTI RACE CONDITION)
	InfluenceQueue = {}
}

-- =========================================================
-- ⚙️ WORLD PROCESSOR (GLOBAL ONLY - FIXED TICK ISSUE)
-- =========================================================
task.spawn(function()
	while true do
		task.wait(0.5)

		World.Tick += 1

		-- apply influence safely
		for _,i in ipairs(World.InfluenceQueue) do
			if i.type == "economy" then
				World.Economy += i.value
			elseif i.type == "chaos" then
				World.Chaos += i.value
			end
		end
		table.clear(World.InfluenceQueue)

		-- economy drift
		if World.Tick % 15 == 0 then
			World.Economy += math.random(-2,2)
		end

		-- faction drift
		if World.Tick % 25 == 0 then
			local change = math.random(-3,3)
			World.Factions.Order += change
			World.Factions.Chaos -= change
		end

		-- events
		if World.Tick % 60 == 0 then
			local events = {"normal","war","peace","famine","boom","rebellion"}
			World.Event = events[math.random(1,#events)]
		end

		-- evolution pressure
		if World.Economy < 40 then
			World.EvolutionRate += 1
		end

		if World.Event == "war" then
			World.HistoricalPressure += 1
		end

		if World.HistoricalPressure > 50 then
			World.Stability -= 1
		end
	end
end)

-- =========================================================
-- 🧬 NPC CLASS
-- =========================================================
local NPC = {}
NPC.__index = NPC

function NPC.new(model)
	local self = setmetatable({}, NPC)

	self.Model = model
	self.Humanoid = model:WaitForChild("Humanoid")
	self.Root = model:WaitForChild("HumanoidRootPart")
	self.Head = model:WaitForChild("Head")

	self.Mood = 100
	self.Emotion = "calm"

	self.Trait = ({"Friendly","Shy","Grumpy","Curious","Logical"})[math.random(1,5)]

	self.DNA = {
		social = math.random(),
		intelligence = math.random(),
		adaptation = math.random()
	}

	self.Dynasty = {
		generation = 1,
		influence = math.random(40,100)
	}

	self.Job = ({"Farmer","Guard","Trader","Hunter","Worker"})[math.random(1,5)]
	self.Money = math.random(20,80)

	self.Memory = {
		trust = 0,
		adaptationLevel = 0
	}

	-- ⚙️ PERFORMANCE CONTROL (SCAN SYSTEM)
	self.LastChat = 0
	self.LastMove = 0
	self.LastTarget = nil
	self.PathBusy = false

	self.Settings = {
		Vision = 60,
		ChatRange = 25,
		UpdateRate = 0.5,
		PathCooldown = 1.2,
		ChatCooldown = 2.5
	}

	return self
end

-- =========================================================
-- ❤️ EMOTION SYSTEM
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

	if World.Event == "war" then
		self.Mood -= 0.2
	elseif World.Event == "peace" then
		self.Mood += 0.1
	end

	self.Mood = math.clamp(self.Mood, 0, 100)
end

-- =========================================================
-- 🧠 SELF EVOLUTION (NOW STABLE + CONTROLLED)
-- =========================================================
function NPC:SelfEvolve()
	self.Memory.adaptationLevel += self.DNA.adaptation * 0.01

	-- controlled dynasty evolution
	if math.random() < 0.0008 then
		self.Dynasty.generation += 1
		self.Dynasty.influence += math.random(1,3)
	end

	-- trait drift (less chaotic)
	if self.Memory.adaptationLevel > 8 then
		if math.random() < 0.01 then
			self.Trait = ({"Friendly","Shy","Grumpy","Curious","Logical"})[math.random(1,5)]
		end
	end

	-- trader economy effect
	if self.Job == "Trader" then
		table.insert(World.InfluenceQueue, {
			type = "economy",
			value = (World.Economy > 120 and 1 or 0)
		})
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

	for _,p in ipairs(Players:GetPlayers()) do
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
-- 🧠 DECISION ENGINE (IMPROVED EMERGENT + LESS LINEAR)
-- =========================================================
function NPC:Think(dist)

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
		score.talk += 8
	end

	-- DNA influence (less deterministic, more emergent)
	score.talk += self.DNA.social * math.random(1,6)
	score.follow += self.DNA.intelligence * math.random(1,4)

	-- trait bias
	if self.Trait == "Friendly" then
		score.talk += 4
	elseif self.Trait == "Grumpy" then
		score.idle += 6
	elseif self.Trait == "Logical" then
		score.work += 5
	end

	-- job bias
	if self.Job == "Trader" then
		score.trade += 6
	elseif self.Job == "Guard" then
		score.follow += 3
	end

	-- world event influence
	if World.Event == "war" then
		score.follow += 2
		score.idle += 1
	end

	if self.Emotion == "angry" then
		score.idle += 8
	end

	-- dynasty influence
	score.talk += self.Dynasty.influence * 0.01

	-- FINAL PICK
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
-- 🚶 MOVEMENT SYSTEM (SCAN OPTIMIZED PATH CACHE)
-- =========================================================
function NPC:Move(target)
	if self.PathBusy then return end
	if os.clock() - self.LastMove < self.Settings.PathCooldown then return end

	if self.LastTarget and (self.LastTarget - target).Magnitude < 5 then
		return
	end

	self.LastMove = os.clock()
	self.LastTarget = target
	self.PathBusy = true

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

		self.PathBusy = false
	end)
end

-- =========================================================
-- 🧠 MAIN LOOP (STABLE SIMULATION CORE)
-- =========================================================
function NPC:Start()
	while self.Humanoid.Health > 0 do
		task.wait(self.Settings.UpdateRate)

		self:UpdateEmotion()
		self:SelfEvolve()

		local player, dist = self:GetClosestPlayer()

		if player and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")

			if hrp then
				local action = self:Think(dist)

				if action == "follow" then
					self:Move(hrp.Position)

				elseif action == "talk" then
					self.Memory.trust += 1
					self:Say("Dunia ini terus berkembang...")

				elseif action == "trade" then
					self.Money += 1
					self:Say("Ekonomi bergerak.")

				elseif action == "work" then
					self:Say(self.Job .. " sedang bekerja.")

				else
					self.Memory.trust -= 0.05
				end

				self.Memory.trust = math.clamp(self.Memory.trust, -100, 100)
			end
		else
			self.Mood = math.max(self.Mood - 0.05, 0)
		end
	end
end

return NPC