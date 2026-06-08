
-- ==================================================
-- 🧠 NPC SISTEM CERDAS - V1.1 STABLE PATCH
-- ==================================================

local npc = script.Parent
local humanoid = npc:WaitForChild("Humanoid")
local root = npc:WaitForChild("HumanoidRootPart")
local head = npc:WaitForChild("Head")

humanoid.BreakJointsOnDeath = false
humanoid.RequiresNeck = false

pcall(function()
	if root:GetNetworkOwner() then
		root:SetNetworkOwner(nil)
	end
end)

local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local PathfindingService = game:GetService("PathfindingService")

-- =========================
-- ⚙️ SETTINGS
-- =========================
local Settings = {
	VisionRange = 45,
	ChatRange = 35,
	FollowRange = 25,
	SafeDistance = 3,
	RoamRange = 50,
	MoodChangeSpeed = 0.15,
	ChatCooldown = 4,
	UpdateRate = 0.5,
	PathCooldown = 0.8
}

-- =========================
-- 📊 DATA
-- =========================
local mood = 100
local memory = {}
local lastChatTime = 0
local lastPathTime = 0
local isClimbing = false

local favoritePlace = root.Position + Vector3.new(math.random(-50,50),0,math.random(-50,50))

-- =========================
-- 😄 EMOJI
-- =========================
local emoticons = {
	happy = {"😊","😄","😁","😆"},
	sad = {"😔","🥲","😢"},
	surprise = {"😲","😳"},
	calm = {"🙂","😌"}
}

local function getEmoji(type)
	return emoticons[type] and emoticons[type][math.random(#emoticons[type])] or ""
end

-- =========================
-- 💬 DIALOG
-- =========================
local personality = {
	newPlayer = {
		happy = {"Halo pemain baru!", "Wih ada pendatang baru!", "Senang ketemu kamu!"}
	},
	oldPlayer = {
		happy = {"Kamu lagi!", "Asik ketemu kamu lagi!"},
		sad = {"Akhirnya kamu balik...", "Aku kangen kamu..."}
	},
	roaming = {
		happy = {"Enak banget suasananya", "Jalan-jalan santai..."},
		complain = {"Sepi banget...", "Gak ada teman..."},
		favorite = {"Tempat favoritku...", "Akhirnya tenang..."}
	}
}

-- =========================
-- UTIL
-- =========================
local function pick(t)
	return t[math.random(#t)]
end

local function say(text, moodType)
	if not text then return end
	if os.clock() - lastChatTime < Settings.ChatCooldown then return end

	lastChatTime = os.clock()

	local msg = text
	if moodType then
		msg = text .. " " .. getEmoji(moodType)
	end

	Chat:Chat(head, msg, Enum.ChatColor.White)
end

-- =========================
-- VISIBILITY (FIXED SAFE RAYCAST)
-- =========================
local function canSee(targetPart)
	if not targetPart then return false end

	local origin = head.Position
	local dir = (targetPart.Position - origin)

	if dir.Magnitude > Settings.VisionRange then
		return false
	end

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {npc}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, dir, params)

	if result then
		return result.Instance:IsDescendantOf(targetPart.Parent)
	end

	return true
end

-- =========================
-- MOVE SYSTEM (ANTI-SPAM FIX)
-- =========================
local function moveSmart(target)
	if os.clock() - lastPathTime < Settings.PathCooldown then return end
	lastPathTime = os.clock()

	if (root.Position - target).Magnitude < Settings.SafeDistance then return end

	task.spawn(function()
		local path = PathfindingService:CreatePath({
			AgentRadius = 2,
			AgentHeight = 5,
			AgentCanJump = true,
			AgentCanClimb = true
		})

		local ok = pcall(function()
			path:ComputeAsync(root.Position, target)
		end)

		if ok and path.Status == Enum.PathStatus.Success then
			local wp = path:GetWaypoints()
			if wp[2] then
				humanoid:MoveTo(wp[2].Position)
				if wp[2].Action == Enum.PathAction.Jump then
					humanoid.Jump = true
				end
			end
		else
			humanoid:MoveTo(target)
		end
	end)
end

-- =========================
-- CLIMB FIX (NO FREEZE RISK)
-- =========================
local function tryClimb()
	if isClimbing then return end

	local origin = root.Position + Vector3.new(0,1,0)
	local dir = root.CFrame.LookVector * 6

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {npc}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, dir, params)

	if result and result.Instance then
		local name = string.lower(result.Instance.Name)

		if name:find("tree") or name:find("trunk") then
			isClimbing = true
			humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
			root.AssemblyLinearVelocity = Vector3.new(0,22,0)

			task.delay(0.5, function()
				isClimbing = false
			end)
		end
	end
end

-- =========================
-- PLAYER FINDER
-- =========================
local function getClosestPlayer()
	local closest, dist = nil, math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")

		if hrp then
			local d = (hrp.Position - root.Position).Magnitude
			if d < dist then
				dist = d
				closest = p
			end
		end
	end

	return closest, dist
end

-- =========================
-- MAIN LOOP
-- =========================
while task.wait(Settings.UpdateRate) do
	local player, dist = getClosestPlayer()

	if player and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")

		if hrp and dist < Settings.VisionRange and canSee(hrp) then

			if not memory[player.UserId] then
				memory[player.UserId] = {count = 1, last = os.clock()}
			elseif os.clock() - memory[player.UserId].last > 3 then
				memory[player.UserId].count += 1
				memory[player.UserId].last = os.clock()
			end

			if dist < Settings.FollowRange then
				moveSmart(hrp.Position)
				mood = math.min(mood + 0.2, 100)

				if dist < Settings.ChatRange then
					local mem = memory[player.UserId]

					if mem.count == 1 then
						say(pick(personality.newPlayer.happy), "happy")
					else
						say(pick(personality.oldPlayer.happy), "happy")
					end
				end

				if dist < 12 then
					tryClimb()
				end
			end

		else
			mood = math.max(mood - Settings.MoodChangeSpeed, 0)
		end

	else
		-- roaming
		mood = math.max(mood - 0.1, 0)

		if mood < 40 then
			moveSmart(favoritePlace)
		else
			if math.random() < 0.2 then
				favoritePlace = root.Position + Vector3.new(
					math.random(-Settings.RoamRange, Settings.RoamRange),
					0,
					math.random(-Settings.RoamRange, Settings.RoamRange)
				)
			end
			moveSmart(favoritePlace)
		end
	end

	-- random idle chat
	if math.random() < 0.04 then
		if mood > 60 then
			say(pick(personality.roaming.happy), "happy")
		elseif mood < 30 then
			say(pick(personality.roaming.complain), "sad")
		end
	end
end