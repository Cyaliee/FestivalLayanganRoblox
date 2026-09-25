--!strict
--[[
	Turunkan nilai tampilan (teks, progress, dll) dari data mentah pemain.
	Dipakai PlayerState (data asli dari server) dan story UI Labs (data mock).

	raw: { Coins, Level, Exp, BagTier, TableLevel, Inventory } — masing-masing boleh Value atau konstanta
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = require(ReplicatedStorage.Shared.Config.Items)
local HotbarConfig = require(ReplicatedStorage.Shared.Config.Hotbar)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local Bag = require(ReplicatedStorage.Shared.Rules.Bag)
local Progression = require(ReplicatedStorage.Shared.Rules.Progression)
local Format = require(ReplicatedStorage.Shared.Util.Format)

export type HotbarItem = { Id: string, Count: number }

local PlayerView = {}

-- Item di hotbar: count > 0, kategori yang diizinkan, urut Order, maks SlotCount
function PlayerView.hotbarItems(inventory: { [string]: number }): { HotbarItem }
	local list: { HotbarItem } = {}
	for id, count in inventory do
		local def = Items[id]
		if def and count > 0 and HotbarConfig.Categories[def.Category] then
			table.insert(list, { Id = id, Count = count })
		end
	end
	table.sort(list, function(a, b)
		return Items[a.Id].Order < Items[b.Id].Order
	end)
	while #list > HotbarConfig.SlotCount do
		table.remove(list)
	end
	return list
end

function PlayerView.derive(scope: any, raw: any)
	local function computed(fn)
		return scope:Computed(fn)
	end

	local bagUsed = computed(function(use)
		return Bag.used(use(raw.Inventory))
	end)
	local bagCapacity = computed(function(use)
		return Bag.capacity(use(raw.BagTier))
	end)

	return {
		Level = computed(function(use)
			return use(raw.Level)
		end),
		LevelText = computed(function(use)
			return string.format(UIText.LevelShort, use(raw.Level))
		end),
		ExpProgress = computed(function(use)
			local level = use(raw.Level)
			if Progression.isMaxLevel(level) then
				return 1
			end
			return use(raw.Exp) / Progression.expToNext(level)
		end),
		ExpText = computed(function(use)
			local level = use(raw.Level)
			if Progression.isMaxLevel(level) then
				return UIText.ExpMax
			end
			return string.format(
				UIText.ExpFormat,
				Format.number(use(raw.Exp)),
				Format.number(Progression.expToNext(level))
			)
		end),
		CoinsText = computed(function(use)
			return Format.number(use(raw.Coins))
		end),
		BambooText = computed(function(use)
			return Format.number(use(raw.Inventory).Bamboo or 0)
		end),
		KiteText = computed(function(use)
			return Format.number(Bag.countCategory(use(raw.Inventory), "Kite"))
		end),
		BagUsed = bagUsed,
		BagCapacity = bagCapacity,
		BagText = computed(function(use)
			return string.format(UIText.BagFormat, use(bagUsed), use(bagCapacity))
		end),
		BagFull = computed(function(use)
			return use(bagUsed) >= use(bagCapacity)
		end),
		TableLevel = computed(function(use)
			return use(raw.TableLevel)
		end),
		HotbarItems = computed(function(use)
			return PlayerView.hotbarItems(use(raw.Inventory))
		end),
	}
end

return PlayerView
