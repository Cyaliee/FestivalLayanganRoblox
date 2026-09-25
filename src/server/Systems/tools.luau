--!strict
-- Pastikan setiap pemain punya kapak di Backpack (juga setelah respawn).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local ToolService = require(script.Parent.Parent.Services.ToolService)

local function tools(world)
	if not Matter.useThrottle(0.5) then
		return
	end
	for _, entity in world:query(Components.PlayerEntity) do
		if entity.player.Character then
			ToolService.ensureAxe(entity.player)
		end
	end
end

return { system = tools, priority = 5 }
