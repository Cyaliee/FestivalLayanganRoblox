--!strict
-- Validasi server-side untuk semua aksi pemain.

local Validation = {}

function Validation.getRootPart(player: Player): BasePart?
	local character = player.Character
	if character == nil then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

-- true kalau karakter pemain hidup & dalam jarak maxDistance dari position
function Validation.isWithinDistance(player: Player, position: Vector3, maxDistance: number): boolean
	local root = Validation.getRootPart(player)
	if root == nil then
		return false
	end
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Health <= 0 then
		return false
	end
	return (root.Position - position).Magnitude <= maxDistance
end

return Validation
