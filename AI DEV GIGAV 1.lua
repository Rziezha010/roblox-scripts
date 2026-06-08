-- ==================================================
-- 🧠 NPC SISTEM CERDAS - DEV.GIGA V I (OPTIMIZED)
-- ==================================================

local npc = script.Parent
local humanoid = npc:WaitForChild("Humanoid")
local root = npc:WaitForChild("HumanoidRootPart")
local head = npc:WaitForChild("Head")

humanoid.BreakJointsOnDeath = false
humanoid.RequiresNeck = false

-- Mengamankan network owner agar fisiknya mulus dikontrol server
pcall(function()
	if root:GetNetworkOwner() ~= nil then
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
	MoodChangeSpeed = 0.2,
	ChatCooldown = 4,
	UpdateRate = 0.5
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
-- 😄 EMOTICON SYSTEM
-- =========================
local emoticons = {
	happy = {"😊", "😄", "😁", "😆"},
	sad = {"😔", "🥲", "😢"},
	surprise = {"😲", "😳", "😯"},
	calm = {"🙂", "😌"}
}

local function getEmoji(type)
	return emoticons[type][math.random(#emoticons[type])]
end

-- =========================
-- 💬 DIALOG (REVISI: Emoji dilepas agar dinamis saat dipanggil)
-- =========================
local personality = {
	newPlayer = {
		happy = {"Halo pemain baru!", "Wih ada pendatang baru!", "Senang ketemu kamu!"},
		sad = {"Halo...", "Aku lagi agak sepi nih..."}
	},
	oldPlayer = {
		happy = {"Kamu lagi!", "Asik ketemu kamu lagi! 😆"},
		sad = {"Akhirnya kamu balik...", "Aku kangen kamu tadi..."}
	},
	roaming = {
		happy = {"Enak banget suasananya", "Jalan-jalan santai..."},
		complain = {"Sepi banget...", "Gak ada teman ngobrol..."},
		favorite = {"Tempat favoritku...", "Akhirnya tenang di sini."}
	}
}

-- =========================
-- 🛠️ UTIL
-- =========================
local function pick(list)
	return list[math.random(#list)]
end

-- REVISI: Fungsi say sekarang otomatis menempelkan emoji acak di akhir teks
local function say(text, moodType)
	if not text then return end
	if os.clock() - lastChatTime < Settings.ChatCooldown then return end

	lastChatTime = os.clock()
	
	local gabungTeks = text
	if moodType then
		gabungTeks = text .. " " .. getEmoji(moodType)
	end
	
	Chat:Chat(head, gabungTeks, Enum.ChatColor.White)
end

-- =========================
-- 👁️ VISIBILITY CHECK
-- =========================
local function canSee(targetPart)
	local origin = head.Position
	local direction = (targetPart.Position - origin).Unit * Settings.VisionRange

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {npc}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction, params)
	return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

-- =========================
-- 🚶 PATH SYSTEM (REVISI: Menggunakan task.spawn agar anti-lag)
-- =========================
local function moveSmart(targetPosition)
	if os.clock() - lastPathTime < 0.7 then return end
	lastPathTime = os.clock()

	if (root.Position - targetPosition).Magnitude < Settings.SafeDistance then return end

	-- Dibungkus task.spawn agar looping jalan tidak menyumbat main loop script
	task.spawn(function()
		local path = PathfindingService:CreatePath({
			AgentRadius = 2,
			AgentHeight = 5,
			AgentCanJump = true,
			AgentCanClimb = true
		})

		path:ComputeAsync(root.Position, targetPosition)

		if path.Status == Enum.PathStatus.Success then
			local waypoints = path:GetWaypoints()
			-- Cukup ambil waypoint terdekat agar gerakan dinamis mengikuti target yang bergerak
			if waypoints[2] then
				humanoid:MoveTo(waypoints[2].Position)
				if waypoints[2].Action == Enum.PathAction.Jump then
					humanoid.Jump = true
				end
			end
		else
			humanoid:MoveTo(targetPosition)
		end
	end)
end

-- =========================
-- 🌳 CLIMB SYSTEM
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

		if string.find(name,"tree") or string.find(name,"trunk") then
			isClimbing = true
			humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
			root.AssemblyLinearVelocity = Vector3.new(0,25,0)
			task.wait(0.4)
			isClimbing = false
		end
	end
end

-- =========================
-- 👤 PLAYER FINDER
-- =========================
local function getClosestPlayer()
	local closest, dist = nil, math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local d = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
			if d < dist then
				dist = d
				closest = p
			end
		end
	end

	return closest, dist
end

-- =========================
-- 🧠 MAIN LOOP
-- =========================
while true do
	task.wait(Settings.UpdateRate)

	local player, dist = getClosestPlayer()

	if player and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		
		-- REVISI: Cek validasi penglihatan dulu sebelum memproses memory & pergerakan
		if hrp and dist < Settings.VisionRange and canSee(hrp) then
			
			-- REVISI: Memory dihitung berdasar player yang BENAR-BENAR TERLIHAT
			if not memory[player.UserId] then
				memory[player.UserId] = { name = player.Name, count = 1 }
			else
				-- Batasi penambahan counter agar tidak meledak angkanya setiap 0.5 detik
				if os.clock() - lastChatTime > Settings.ChatCooldown then
					memory[player.UserId].count = memory[player.UserId].count + 1
				end
			end

			if dist < Settings.FollowRange then
				moveSmart(hrp.Position)
				mood = math.min(mood + 0.3, 100)

				if dist < Settings.ChatRange then
					if memory[player.UserId].count == 1 then
						if mood > 50 then say(pick(personality.newPlayer.happy), "happy") else say(pick(personality.newPlayer.sad), "sad") end
					else
						if mood > 50 then say(pick(personality.oldPlayer.happy), "happy") else say(pick(personality.oldPlayer.sad), "sad") end
					end
				end

				if dist < 12 then tryClimb() end
			end
		else
			-- Ada player tapi tidak kelihatan/jauh
			mood = math.max(mood - Settings.MoodChangeSpeed, 0)
		end
	else
		-- Roaming total (Sepi)
		mood = math.max(mood - 0.1, 0)

		if mood < 40 then
			moveSmart(favoritePlace)
			if math.random() < 0.1 then
				say(pick(personality.roaming.favorite), "calm")
			end
		else
			-- Buat titik random baru hanya sesekali agar jalannya tidak patah-patah berganti arah
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

	-- Random chat ringan saat roaming santai
	if math.random() < 0.05 then
		if mood > 60 then
			say(pick(personality.roaming.happy), "happy")
		elseif mood < 30 then
			say(pick(personality.roaming.complain), "sad")
		end
	end
end
