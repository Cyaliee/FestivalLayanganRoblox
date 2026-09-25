--!strict
-- Lepas kavling saat pemiliknya keluar dari server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.Components)

local Owner = Components.Owner

local function releasePlots(world)
	local released = {}
	for id, owner in world:query(Owner) do
		if owner.player.Parent ~= Players then
			table.insert(released, id)
		end
	end
	for _, id in released do
		world:remove(id, Owner)
	end
end

return { system = releasePlots, priority = 20 }
