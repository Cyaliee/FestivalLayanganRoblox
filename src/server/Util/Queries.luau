--!strict
-- Query ECS yang sering dipakai beberapa system.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Shared.Components)

local Queries = {}

-- Entity id kavling milik pemain, atau nil
function Queries.plotOwnedBy(world: any, player: Player): number?
	for id, owner in world:query(Components.Owner, Components.Plot) do
		if owner.player == player then
			return id
		end
	end
	return nil
end

-- true kalau data pemain sudah dimuat (punya PlayerEntity)
function Queries.isPlayerLoaded(world: any, player: Player): boolean
	for _, playerEntity in world:query(Components.PlayerEntity) do
		if playerEntity.player == player then
			return true
		end
	end
	return false
end

-- Entity id PlayerEntity milik pemain, atau nil
function Queries.playerEntityId(world: any, player: Player): number?
	for id, playerEntity in world:query(Components.PlayerEntity) do
		if playerEntity.player == player then
			return id
		end
	end
	return nil
end

-- Kavling + Meja Rakit milik pemain: (plotId, plot, craftingTable) atau nil
function Queries.tableOf(world: any, player: Player): (number?, any, any)
	for id, owner, plot, craftingTable in world:query(Components.Owner, Components.Plot, Components.CraftingTable) do
		if owner.player == player then
			return id, plot, craftingTable
		end
	end
	return nil, nil, nil
end

return Queries
