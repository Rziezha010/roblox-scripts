local rig = script.Parent

local rigHumanoid = rig:FindFirstChildOfClass("Humanoid")
if not rigHumanoid then return end

-- Auto ProximityPrompt
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Morph"
prompt.ObjectText = rig.Name
prompt.MaxActivationDistance = 10
prompt.RequiresLineOfSight = false
prompt.Parent = rig:FindFirstChild("HumanoidRootPart") or rig

prompt.Triggered:Connect(function(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Morph player
    local description = rigHumanoid:GetAppliedDescription()
    humanoid:ApplyDescription(description)
    
    -- Show EXISTING button
    local playerGui = player:WaitForChild("PlayerGui")
    local gui = playerGui:FindFirstChild("YourGui")
    if gui then
        local button = gui:FindFirstChild("YourButton", true)
        if button then
            button.Visible = true
        end
    end
end)

