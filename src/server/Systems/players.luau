--!strict
-- Sinkron PlayerEntity dengan pemain yang datanya sudah dimuat.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.Components)
local DataService = require(script.Parent.Parent.Services.DataService)

local PlayerEntity = Components.PlayerEntity

local function players(world)
	local tracked: { [Player]: boolean } = {}
	local toDespawn = {}

	for id, entity in world:query(PlayerEntity) do
		if entity.player.Parent ~= Players or not DataService.isLoaded(entity.player) then
			table.insert(toDespawn, id)
		else
			tracked[entity.player] = true
		end
	end

	for _, id in toDespawn do
		world:despawn(id)
	end

	for _, player in Players:GetPlayers() do
		if not tracked[player] and DataService.isLoaded(player) then
			world:spawn(PlayerEntity({ player = player, userId = player.UserId }))
		end
	end
end

return { system = players, priority = 0 }
