-- =================================================================
-- 🧠 NPC SISTEM CERDAS - V2 REVISED STABLE EDITION
-- Fix: bug, performance, stability, memory logic
-- =================================================================

local npc = script.Parent
local humanoid = npc:WaitForChild("Humanoid")
local root = npc:WaitForChild("HumanoidRootPart")
local head = npc:WaitForChild("Head")

humanoid.BreakJointsOnDeath = false
humanoid.RequiresNeck = false
humanoid.JumpPower = 50
humanoid.WalkSpeed = 6

pcall(function()
	if not root.Anchored then
		root:SetNetworkOwner(nil)
	end
end)

local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local PathfindingService = game:GetService("PathfindingService")

-- ==========================================
-- ⚙️ SETTINGS
-- ==========================================
local Settings = {
	VisionRange = 45,
	ChatRange = 35,
	FollowRange = 28,
	SafeDistance = 5,
	RoamRange = 50,
	ChatCooldown = 4,
	UpdateRate = 0.5,
	PathCooldown = 1,
	ClimbDetectRange = 6
}

local Traits = {"Friendly", "Shy", "Grumpy", "Curious"}

-- ==========================================
-- 🧠 NPC DATA
-- ==========================================
local npcData = {
	identity = { id = "NPC_" .. math.random(1000, 9999) },
	trait = Traits[math.random(#Traits)],
	mood = 100,
	memory = {},
	lastChat = { topic = nil, time = 0 },
	timers = { lastChatTime = 0, lastPathTime = 0, lastIdleMove = 0 },
	states = {
		isClimbing = false,
		isPathComputing = false,
		favoritePlace = root.Position,
		currentTarget = nil
	}
}

print(("✅ SPAWN: %s | TRAIT: %s"):format(npcData.identity.id, npcData.trait))

-- ==========================================
-- PATH SETUP
-- ==========================================
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {npc}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local agentPath = PathfindingService:CreatePath({
	AgentRadius = 2.2,
	AgentHeight = 5.5,
	AgentCanJump = true,
	AgentCanClimb = true,
	WaypointSpacing = 3
})

local lastPathTarget = Vector3.zero

-- ==========================================
-- UTIL
-- ==========================================
local function pick(t)
	return t[math.random(#t)]
end

local function canSee(targetPart)
	if not targetPart then return false end

	local origin = head.Position
	local dir = (targetPart.Position - origin)
	local dist = dir.Magnitude

	if dist > Settings.VisionRange then return false end

	local result = workspace:Raycast(origin, dir, raycastParams)

	if result then
		return result.Instance:IsDescendantOf(targetPart.Parent)
	end

	return true
end

-- ==========================================
-- SPEECH SYSTEM
-- ==========================================
local function say(text)
	if not text then return end
	if os.clock() - npcData.timers.lastChatTime < Settings.ChatCooldown then return end

	npcData.timers.lastChatTime = os.clock()
	Chat:Chat(head, text, Enum.ChatColor.White)
end

-- ==========================================
-- MEMORY + CHAT PARSER
-- ==========================================
local function updateMemory(msg)
	msg = string.lower(msg)

	if msg:find("halo") or msg:find("hai") then
		return "halo"
	elseif msg:find("ikut") then
		return "ikut"
	elseif msg:find("siapa") then
		return "siapa"
	elseif msg:find("jelek") or msg:find("bodoh") then
		npcData.mood = math.max(npcData.mood - 20, 0)
		return "marah"
	end

	return "lainnya"
end

-- ==========================================
-- MOVE SMART (FIXED)
-- ==========================================
local function moveSmart(target)
	if os.clock() - npcData.timers.lastPathTime < Settings.PathCooldown then return end
	npcData.timers.lastPathTime = os.clock()

	npcData.states.currentTarget = target

	if (root.Position - target).Magnitude < Settings.SafeDistance then
		humanoid:Move(Vector3.zero)
		return
	end

	task.spawn(function()
		if npcData.states.isPathComputing then return end
		npcData.states.isPathComputing = true

		if (lastPathTarget - target).Magnitude > 3 then
			lastPathTarget = target
			pcall(function()
				agentPath:ComputeAsync(root.Position, target)
			end)
		end

		if agentPath.Status == Enum.PathStatus.Success then
			local wp = agentPath:GetWaypoints()
			if wp[2] then
				humanoid:MoveTo(wp[2].Position)
				if wp[2].Action == Enum.PathAction.Jump then
					humanoid.Jump = true
				end
			end
		else
			humanoid:MoveTo(target)
		end

		npcData.states.isPathComputing = false
	end)
end

-- ==========================================
-- PLAYER DETECTION
-- ==========================================
local function getClosestPlayer()
	local closest, minDist = nil, math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		local hum = c and c:FindFirstChildOfClass("Humanoid")

		if hrp and hum and hum.Health > 0 then
			local d = (hrp.Position - root.Position).Magnitude
			if d < minDist then
				minDist = d
				closest = p
			end
		end
	end

	return closest, minDist
end

-- ==========================================
-- CHAT BIND
-- ==========================================
local function bindPlayer(player)
	player.Chatted:Connect(function(msg)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if not hrp then return end
		if (hrp.Position - root.Position).Magnitude > Settings.ChatRange then return end

		local topic = updateMemory(msg)

		if topic == "halo" then
			say("Halo juga!")
		elseif topic == "ikut" then
			say("Oke, aku ikut!")
		elseif topic == "siapa" then
			say("Aku " .. npcData.identity.id)
		elseif topic == "marah" then
			say("Hei! Jangan kasar!")
		end
	end)
end

for _, p in ipairs(Players:GetPlayers()) do
	bindPlayer(p)
end

Players.PlayerAdded:Connect(bindPlayer)

Players.PlayerRemoving:Connect(function(p)
	npcData.memory[p.UserId] = nil
end)

-- ==========================================
-- MAIN LOOP
-- ==========================================
while task.wait(Settings.UpdateRate) do
	if humanoid.Health <= 0 then break end

	local player, dist = getClosestPlayer()

	local skor = { Ikut = 0, Ngobrol = 0, JalanJalan = 5 }

	if player then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if hrp and canSee(hrp) then
			skor.Ikut += 10
			if dist < Settings.ChatRange then
				skor.Ngobrol += 10
			end
		end
	end

	-- trait effect ringan
	if npcData.trait == "Shy" then
		skor.Ngobrol -= 3
	elseif npcData.trait == "Friendly" then
		skor.Ikut += 2
		skor.Ngobrol += 3
	elseif npcData.trait == "Grumpy" then
		skor.JalanJalan += 4
	end

	-- EXECUTION
	if player and skor.Ikut > skor.JalanJalan then
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			moveSmart(hrp.Position)

			if dist < Settings.ChatRange and skor.Ngobrol > 5 then
				say("Halo!")
			end
		end
	else
		-- idle
		if os.clock() - npcData.timers.lastIdleMove > 10 then
			npcData.timers.lastIdleMove = os.clock()
			npcData.states.favoritePlace =
				root.Position + Vector3.new(math.random(-40,40),0,math.random(-40,40))
		end

		moveSmart(npcData.states.favoritePlace)
	end
end