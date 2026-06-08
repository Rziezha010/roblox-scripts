-- =========================================================
-- 🧠 DEV.GIGA V5.1 TRUE ECOSYSTEM ENGINE
-- 🌍 V5 + V6 MERGED (SAFE SIMULATION LAYER)
-- ⚙️ STABLE | SCANNED | ROBLOX OPTIMIZED
-- =========================================================

local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local PathfindingService = game:GetService("PathfindingService")

-- =========================================================
-- 🌍 WORLD SIMULATION (ECOSYSTEM LAYER)
-- =========================================================
local World = {
	Time = 0,

	Economy = 100,
	Resources = 100,
	Peace = 70,

	Factions = {
		A = 50,
		B = 50
	},

	Events = "normal"
}

-- =========================================================
-- 🧠 NPC CLASS
-- =========================================================
local NPC = {}
NPC.__index = NPC

function NPC.new(model)
	local self = setmetatable({}, NPC)

	self.Model = model
	self.Humanoid = model:WaitForChild("Humanoid")
	self.Root = model:WaitForChild("HumanoidRootPart")
	self.Head = model:WaitForChild("Head")

	-- CORE
	self.Mood = 100
	self.Emotion = "calm"
	self.Trait = ({"Friendly","Shy","Grumpy","Curious"})[math.random(1,4)]

	-- 🧬 LIFE DATA (ECOSYSTEM)
	self.Job = ({"Farmer","Guard","Trader","Wanderer"})[math.random(1,4)]
	self.Wealth = math.random(10,50)
	self.Faction = (math.random() > 0.5) and "A" or "B"

	-- 🧠 MEMORY (LIMITED)
	self.Memory = {
		trust = 0,
		lastEvents = {}
	}

	-- ⏱ CONTROL
	self.LastChat = 0
	self.LastMove = 0

	self.Settings = {
		Vision = 50,
		ChatRange = 30,
		UpdateRate = 0.6,
		PathCooldown = 0.8,
		ChatCooldown = 3,
		RoamRange = 60
	}

	return self
end

-- =========================================================
-- 🌍 WORLD UPDATE (ECOSYSTEM TICK)
-- =========================================================
function NPC:WorldTick()

	World.Time += 1

	-- economy simulation (ringan)
	if World.Time % 15 == 0 then
		World.Economy += math.random(-2, 3)
		World.Resources -= math.random(0, 2)
	end

	-- faction tension
	if World.Time % 30 == 0 then
		local change = math.random(-5,5)
		World.Factions.A += change
		World.Factions.B -= change
	end

	-- global event
	if World.Time % 60 == 0 then
		local events = {"peace","war","famine","boom"}
		World.Events = events[math.random(1,#events)]
	end
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

	-- world influence
	if World.Events == "war" then
		self.Mood -= 0.5
	elseif World.Events == "peace" then
		self.Mood += 0.2
	end
end

-- =========================================================
-- 💬 CHAT SYSTEM
-- =========================================================
function NPC:Say(msg)
	if os.clock() - self.LastChat < self.Settings.ChatCooldown then return end
	self.LastChat = os.clock()

	local emoji = ""
	if self.Emotion == "happy" then emoji = " 😊"
	elseif self.Emotion == "sad" then emoji = " 😢"
	elseif self.Emotion == "angry" then emoji = " 😠"
	end

	Chat:Chat(self.Head, msg .. emoji, Enum.ChatColor.White)
end

-- =========================================================
-- 👤 PLAYER FINDER
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
-- 🧠 DECISION ENGINE (ECOSYSTEM AWARE)
-- =========================================================
function NPC:Think(player, dist)

	local score = {
		follow = 0,
		talk = 0,
		work = 0,
		idle = 5
	}

	-- basic vision
	if dist < self.Settings.Vision then
		score.follow += 5
	end

	if dist < self.Settings.ChatRange then
		score.talk += 10
	end

	-- JOB SYSTEM influence
	if self.Job == "Farmer" then
		score.work += 5
	elseif self.Job == "Guard" then
		score.follow += 3
	elseif self.Job == "Trader" then
		score.talk += 3
	end

	-- ECONOMY influence
	if World.Economy < 40 then
		score.work += 5
	end

	-- FACTION influence
	if World.Factions[self.Faction] < 40 then
		score.idle += 5
	end

	-- EVENT influence
	if World.Events == "war" then
		score.follow += 3
		score.idle += 2
	end

	-- EMOTION influence
	if self.Emotion == "angry" then
		score.idle += 10
	end

	-- PICK BEST
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
-- 🚶 MOVE SYSTEM
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
-- 🧠 MAIN LOOP
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
					self:Say("Aku hidup di dunia ini...")

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