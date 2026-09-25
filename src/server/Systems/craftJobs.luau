--!strict
-- Selesaikan crafting yang waktunya habis: acak rarity (luck & booster), hasil masuk inventory.
-- Kalau tas penuh, hasil menunggu di meja sampai ada ruang (rarity diacak saat benar-benar masuk).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local Recipes = require(ReplicatedStorage.Shared.Config.Recipes)
local Items = require(ReplicatedStorage.Shared.Config.Items)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local RarityConfig = require(ReplicatedStorage.Shared.Config.Rarity)
local Rarity = require(ReplicatedStorage.Shared.Rules.Rarity)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local InventoryService = require(Server.Services.InventoryService)
local ProgressionService = require(Server.Services.ProgressionService)
local GamepassService = require(Server.Services.GamepassService)
local notify = require(Server.Util.Notify)
local announce = require(Server.Util.Announce)

local rng = Random.new()

local CHECK_INTERVAL = 0.25

local function craftJobs(world)
	if not Matter.useThrottle(CHECK_INTERVAL) then
		return
	end
	local now = workspace:GetServerTimeNow()
	for _, entity in world:query(Components.PlayerEntity) do
		local player = entity.player
		local data = DataService.getData(player)
		local craft = data and data.ActiveCraft
		if data == nil or craft == nil or now < craft.EndsAt then
			continue
		end
		local recipe = Recipes[craft.RecipeId]
		if recipe == nil then
			data.ActiveCraft = nil -- resep sudah dihapus dari config
			continue
		end
		-- Cek ruang dulu (tanpa rarity) supaya acakan tidak "terbuang" saat tas penuh
		local outputDef = Items[recipe.Output]
		local probeKey = ItemKey.make(recipe.Output, recipe.FixedRarity)
		if not InventoryService.canAdd(player, probeKey, recipe.OutputAmount) then
			InventoryService.notifyBagFull(player)
			continue
		end

		local rarity: string? = nil
		if outputDef.HasRarity then
			rarity = recipe.FixedRarity
				or Rarity.roll(GamepassService.luckMultiplier(player), craft.Boosted == true, rng)
		end
		local key = ItemKey.make(recipe.Output, rarity)
		if InventoryService.tryAdd(player, key, recipe.OutputAmount) then
			data.ActiveCraft = nil
			ProgressionService.addExp(player, recipe.Exp)
			notify(player, string.format(Messages.CraftDoneRarity, ItemKey.displayName(key)))
			if rarity and recipe.FixedRarity == nil and Rarity.atLeast(rarity, RarityConfig.AnnounceFrom) then
				announce(string.format(Messages.LegendaryCrafted, player.DisplayName, ItemKey.displayName(key)), "Gold")
			end
		end
	end
end

return { system = craftJobs, priority = 60 }
