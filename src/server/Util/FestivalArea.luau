--!strict
-- Cek apakah posisi berada di Area Festival (Part, atau Folder/Model berisi Part).
-- Hanya sumbu X/Z yang dicek (area berbentuk kolom), jadi tinggi Part tidak masalah.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Shared.Config.World)
local warnOnce = require(script.Parent.WarnOnce)

local FestivalArea = {}

local function getParts(): { BasePart }
	local root = workspace:FindFirstChild(World.FestivalAreaName)
	if root == nil then
		warnOnce("festivalarea", `[Kites] Workspace/{World.FestivalAreaName} tidak ada`)
		return {}
	end
	if root:IsA("BasePart") then
		return { root }
	end
	local parts = {}
	for _, child in root:GetDescendants() do
		if child:IsA("BasePart") then
			table.insert(parts, child)
		end
	end
	return parts
end

function FestivalArea.contains(position: Vector3): boolean
	for _, part in getParts() do
		local localPos = part.CFrame:PointToObjectSpace(position)
		local half = part.Size / 2
		if math.abs(localPos.X) <= half.X and math.abs(localPos.Z) <= half.Z then
			return true
		end
	end
	return false
end

function FestivalArea.containsPlayer(player: Player): boolean
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return root ~= nil and root:IsA("BasePart") and FestivalArea.contains(root.Position)
end

return FestivalArea
