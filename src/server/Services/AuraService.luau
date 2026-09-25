--!strict
-- Registri Aura Naga yang aktif (diisi system dragons tiap frame).
-- Dipakai ProgressionService untuk Social Buff (+EXP pemain lain di dekat naga).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dragon = require(ReplicatedStorage.Shared.Config.Dragon)

export type Aura = { position: Vector3, ownerUserId: number }

local AuraService = {}

local auras: { Aura } = {}

function AuraService.set(list: { Aura })
	auras = list
end

-- true kalau pemain berada di aura naga milik pemain LAIN
function AuraService.hasSocialBuff(player: Player): boolean
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return false
	end
	local position = root.Position
	for _, aura in auras do
		if aura.ownerUserId ~= player.UserId then
			local offset = position - aura.position
			if Vector2.new(offset.X, offset.Z).Magnitude <= Dragon.AuraRadius then
				return true
			end
		end
	end
	return false
end

return AuraService
