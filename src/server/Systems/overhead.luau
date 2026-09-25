--!strict
-- Nametag custom "DisplayName | Lv.xxx" (dibuat client dari attribute Level).
-- Nama bawaan Roblox di atas kepala disembunyikan.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local DataService = require(script.Parent.Parent.Services.DataService)

local LEVEL_ATTRIBUTE = "Level"

local function overhead(world)
	if not Matter.useThrottle(0.25) then
		return
	end
	for _, entity in world:query(Components.PlayerEntity) do
		local player = entity.player
		local data = DataService.getData(player)
		if data and player:GetAttribute(LEVEL_ATTRIBUTE) ~= data.Level then
			player:SetAttribute(LEVEL_ATTRIBUTE, data.Level)
		end
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
	end
end

return { system = overhead, priority = 5 }
