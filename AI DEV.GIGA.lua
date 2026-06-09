-- =========================================================
-- 🌍 DEV.GIGA LIVING CIVILIZATION Ω∞
-- 🧠 FINAL SINGLE PROJECT (REALISTIC EMERGENT SIMULATION)
-- =========================================================

local PathfindingService = game:GetService("PathfindingService")
local Chat = game:GetService("Chat")

-- =========================================================
-- 🌍 WORLD CORE (GLOBAL SIMULATION BRAIN)
-- =========================================================
local World = {
	Tick = 0,
	Event = "normal",

	Resources = {
		Food = 150,
		Wood = 150,
		Gold = 150
	},

	Factions = {A = 50, B = 50}
}

-- =========================================================
-- 🧠 WORLD LOOP (SELF BALANCING SYSTEM)
-- =========================================================
task.spawn(function()
	while true do
		task.wait(0.7)

		World.Tick += 1

		-- natural resource flow
		if World.Tick % 10 == 0 then
			World.Resources.Food += math.random(-2,3)
			World.Resources.Wood += math.random(-2,3)
			World.Resources.Gold += math.random(-1,2)
		end

		-- faction drift
		if World.Tick % 25 == 0 then
			local c = math.random(-3,3)
			World.Factions.A += c
			World.Factions.B -= c
		end

		-- world events
		if World.Tick % 60 == 0 then
			local events = {"normal","war","peace","famine","boom"}
			World.Event = events[math.random(1,#events)]
		end

		-- auto correction (ANTI EXPLOSION SYSTEM)
		for k,v in pairs(World.Resources) do
			World.Resources[k] = math.clamp(v, 0, 500)
		end

		World.Factions.A = math.clamp(World.Factions.A, 0, 100)
		World.Factions.B = math.clamp(World.Factions.B, 0, 100)
	end
end)

-- =========================================================
-- 🧬 NPC CLASS (LIVING AGENT)
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

	-- LIFE STATE
	self.Mood = 100
	self.Emotion = "calm"

	-- PERSONALITY
	self.Trait = ({"Friendly","Trader","Worker","Explorer","Hermit"})[math.random(1,5)]

	-- SURVIVAL NEEDS
	self.Needs = {
		Food = math.random(60,100)
	}

	-- INVENTORY ECONOMY
	self.Inventory = {
		Food = math.random(5,15),
		Wood = math.random(5,15),
		Gold = math.random(2,10)
	}

	-- SOCIAL MEMORY
	self.Reputation = 0

	-- DNA BEHAVIOR CORE
	self.DNA = {
		social = math.random(),
		greed = math.random(),
		curiosity = math.random()
	}

	-- CONTROL
	self.LastMove = 0
	self.LastChat = 0

	self.Settings = {
		Vision = 60,
		UpdateRate = 0.6,
		PathCooldown = 1.2,
		ChatCooldown = 3
	}

	return self
end

-- =========================================================
-- ❤️ EMOTION SYSTEM (REALISTIC STATE MACHINE)
-- =========================================================
function NPC:UpdateEmotion()

	if self.Needs.Food < 30 then
		self.Emotion = "angry"
	elseif self.Mood > 70 then
		self.Emotion = "happy"
	elseif self.Mood > 40 then
		self.Emotion = "calm"
	else
		self.Emotion = "sad"
	end

	if World.Event == "war" then
		self.Mood -= 0.3
	elseif World.Event == "peace" then
		self.Mood += 0.2
	elseif World.Event == "famine" then
		self.Needs.Food -= 0.4
	end

	self.Mood = math.clamp(self.Mood, 0, 100)
	self.Needs.Food = math.clamp(self.Needs.Food, 0, 100)
end

-- =========================================================
-- 👥 SOCIAL DETECTION
-- =========================================================
function NPC:GetClosestNPC(npcs)
	local best, dist = nil, math.huge

	for _, n in ipairs(npcs) do
		if n ~= self and n.Root then
			local d = (n.Root.Position - self.Root.Position).Magnitude
			if d < dist and d < self.Settings.Vision then
				best, dist = n, d
			end
		end
	end

	return best, dist
end

-- =========================================================
-- 🧠 DECISION ENGINE (EMERGENT AI)
-- =========================================================
function NPC:Think(npcDist)

	local score = {
		survive = 2,
		talk = 0,
		trade = 0,
		explore = 0,
		rest = 1
	}

	-- survival pressure
	if self.Needs.Food < 40 then
		score.survive += 8
		score.explore += 4
	end

	-- DNA behavior
	score.talk += self.DNA.social * 4
	score.trade += self.DNA.greed * 3
	score.explore += self.DNA.curiosity * 4

	-- trait logic
	if self.Trait == "Trader" then
		score.trade += 5
	elseif self.Trait == "Explorer" then
		score.explore += 5
	elseif self.Trait == "Hermit" then
		score.rest += 5
	end

	-- social influence
	if npcDist and npcDist < 40 then
		score.talk += 5
		score.trade += 2
	end

	-- world influence
	if World.Event == "boom" then
		score.trade += 4
	elseif World.Event == "famine" then
		score.survive += 6
	elseif World.Event == "war" then
		score.rest += 2
	end

	-- emotion influence
	if self.Emotion == "angry" then
		score.rest += 5
	end

	-- pick best action
	local best, action = -math.huge, "rest"

	for k,v in pairs(score) do
		if v > best then
			best = v
			action = k
		end
	end

	return action
end

-- =========================================================
-- 💬 CHAT SYSTEM
-- =========================================================
function NPC:Say(text)
	if os.clock() - self.LastChat < self.Settings.ChatCooldown then return end
	self.LastChat = os.clock()

	Chat:Chat(self.Head, text, Enum.ChatColor.White)
end

-- =========================================================
-- 🤝 TRADE SYSTEM
-- =========================================================
function NPC:Trade(other)
	if not other then return end

	local item = ({"Food","Wood","Gold"})[math.random(1,3)]
	local amount = math.random(1,2)

	if self.Inventory[item] > amount then
		self.Inventory[item] -= amount
		other.Inventory[item] += amount

		self.Reputation += 1
		other.Reputation += 1
	end
end

-- =========================================================
-- 🚶 MOVEMENT SYSTEM
-- =========================================================
function NPC:Move(target)
	if os.clock() - self.LastMove < self.Settings.PathCooldown then return end
	self.LastMove = os.clock()

	task.spawn(function()
		local path = PathfindingService:CreatePath()

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
-- 🧠 MAIN LIFE LOOP (FULL AUTONOMY)
-- =========================================================
function NPC:Start(npcs)

	while self.Humanoid.Health > 0 do
		task.wait(self.Settings.UpdateRate)

		self:UpdateEmotion()

		local npc, dist = self:GetClosestNPC(npcs)

		local action = self:Think(dist)

		if action == "survive" then
			self.Needs.Food += 1

		elseif action == "talk" then
			self:Say("Aku hidup di dunia ini...")

		elseif action == "trade" then
			self:Trade(npc)

		elseif action == "explore" then
			self:Move(self.Root.Position + Vector3.new(math.random(-15,15),0,math.random(-15,15)))

		elseif action == "rest" then
			self.Needs.Food -= 0.2
		end

		self.Needs.Food -= 0.3
		self.Mood = math.clamp(self.Mood, 0, 100)
	end
end

return NPC