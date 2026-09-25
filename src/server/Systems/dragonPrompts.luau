--!strict
-- Prompt "Pasang Naga" / "Turunkan Naga" di MejaRakit milik sendiri. Maksimal 1 naga per kavling.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local Dragon = require(ReplicatedStorage.Shared.Config.Dragon)
local TableConfig = require(ReplicatedStorage.Shared.Config.CraftingTable)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local InventoryService = require(Server.Services.InventoryService)
local RateLimiter = require(Server.Util.RateLimiter)
local Validation = require(Server.Util.Validation)
local notify = require(Server.Util.Notify)
local announce = require(Server.Util.Announce)

local limiter = RateLimiter.new(NetworkConfig.RateLimits.DragonPrompt)

-- Naga terbaik di inventory (rarity tertinggi)
local function bestDragonKey(inventory: { [string]: number }): string?
	local best, bestRank = nil, -1
	for key, count in inventory do
		local itemId = ItemKey.parse(key)
		local tier = ItemKey.rarity(key)
		if itemId == Dragon.ItemId and count > 0 and tier and tier.Rank > bestRank then
			best, bestRank = key, tier.Rank
		end
	end
	return best
end

local function handle(player: Player, ownerPlayer: Player, tableModel: Model)
	if player.Parent ~= Players or not limiter:check(player) then
		return
	end
	if player ~= ownerPlayer then
		notify(player, Messages.NotYourTable)
		return
	end
	local maxDistance = TableConfig.InteractDistance + TableConfig.DistanceTolerance
	if not Validation.isWithinDistance(player, tableModel:GetPivot().Position, maxDistance) then
		notify(player, Messages.TooFar)
		return
	end
	local data = DataService.getData(player)
	if data == nil then
		return
	end

	if data.PlacedDragon then
		-- Turunkan: kembali ke tas (harus muat)
		if InventoryService.tryAdd(player, data.PlacedDragon, 1) then
			data.PlacedDragon = nil
			notify(player, Messages.DragonLowered)
		end
		return
	end

	local key = bestDragonKey(data.Inventory)
	if key == nil then
		notify(player, Messages.NoDragon)
		return
	end
	if InventoryService.tryRemove(player, key, 1) then
		data.PlacedDragon = key
		announce(string.format(Messages.DragonPlaced, player.DisplayName), "Red")
	end
end

local function dragonPrompts(world)
	for _, craftingTable, owner in world:query(Components.CraftingTable, Components.Owner) do
		if craftingTable.dragonPrompt == nil then
			continue
		end
		for _, player in Matter.useEvent(craftingTable.dragonPrompt, "Triggered") do
			handle(player, owner.player, craftingTable.model)
		end
	end
end

return { system = dragonPrompts, priority = 10 }
