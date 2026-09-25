--!strict
--[[
	Turunkan nilai tampilan (teks, progress, dll) dari data mentah pemain.
	Dipakai PlayerState (data asli dari server) dan story UI Labs (data mock).

	raw: { Coins, Level, Exp, BagLevel, TableLevel, Inventory } — masing-masing boleh Value atau konstanta
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)
local HotbarConfig = require(ReplicatedStorage.Shared.Config.Hotbar)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local Bag = require(ReplicatedStorage.Shared.Rules.Bag)
local Progression = require(ReplicatedStorage.Shared.Rules.Progression)
local TableRules = require(ReplicatedStorage.Shared.Rules.CraftingTable)
local Recipes = require(ReplicatedStorage.Shared.Config.Recipes)
local Format = require(ReplicatedStorage.Shared.Util.Format)

-- Id = item key ("Bamboo", "Kite@Epic") atau id tool ("Axe")
export type HotbarItem = { Id: string, Count: number, IsTool: boolean? }

local PlayerView = {}

-- Isi hotbar: slot tool (kapak) dulu, lalu item yang dipasang pemain dari Inventory (count > 0)
function PlayerView.hotbarItems(inventory: { [string]: number }, hotbar: { string }?): { HotbarItem }
	local tools: { HotbarItem } = {}
	for _, toolId in HotbarConfig.Tools do
		table.insert(tools, { Id = toolId, Count = 0, IsTool = true })
	end

	local list: { HotbarItem } = tools
	for _, key in hotbar or {} do
		local count = inventory[key] or 0
		if count > 0 and ItemKey.isValid(key) then
			table.insert(list, { Id = key, Count = count })
		end
	end
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
		return Bag.capacity(use(raw.BagLevel))
	end)
	local bagPrice = computed(function(use)
		return Bag.upgradePrice(use(raw.BagLevel))
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
		MoneyText = computed(function(use)
			return string.format(UIText.CoinFormat, Format.number(use(raw.Coins)))
		end),
		LevelCardText = computed(function(use)
			return string.format(UIText.LevelCard, use(raw.Level))
		end),
		ExpShortText = computed(function(use)
			local level = use(raw.Level)
			if Progression.isMaxLevel(level) then
				return UIText.ExpMax
			end
			return string.format(
				UIText.ExpShort,
				Format.number(use(raw.Exp)),
				Format.number(Progression.expToNext(level))
			)
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
		BagLevel = computed(function(use)
			return use(raw.BagLevel)
		end),
		BagLevelText = computed(function(use)
			return string.format(UIText.BagLevel, use(raw.BagLevel))
		end),
		BagUsageText = computed(function(use)
			return string.format(UIText.BagUsage, Format.number(use(bagUsed)), Format.number(use(bagCapacity)))
		end),
		BagNextText = computed(function(use)
			local level = use(raw.BagLevel)
			if use(bagPrice) == nil then
				return UIText.BagMaxLevel
			end
			return string.format(UIText.BagNext, level + 1, Format.number(Bag.capacity(level + 1)))
		end),
		BagCostText = computed(function(use)
			local price = use(bagPrice)
			return string.format(UIText.BagCost, if price then Format.number(price) else "-")
		end),
		BagIsMax = computed(function(use)
			return use(bagPrice) == nil
		end),
		BagCanAfford = computed(function(use)
			local price = use(bagPrice)
			return price ~= nil and use(raw.Coins) >= price
		end),
		TableLevel = computed(function(use)
			return use(raw.TableLevel)
		end),
		TableIsMax = computed(function(use)
			return TableRules.upgradeCost(use(raw.TableLevel)) == nil
		end),
		TableCostText = computed(function(use)
			local cost = TableRules.upgradeCost(use(raw.TableLevel))
			return if cost then Format.number(cost) else UIText.CostUnknown
		end),
		TableCanAfford = computed(function(use)
			local cost = TableRules.upgradeCost(use(raw.TableLevel))
			return cost ~= nil and use(raw.Coins) >= cost
		end),
		TableInfoText = computed(function(use)
			local level = use(raw.TableLevel)
			if TableRules.upgradeCost(level) == nil then
				return string.format(UIText.TableSpeed, TableRules.speed(level))
			end
			local text = string.format(UIText.TableSpeedNext, TableRules.speed(level), TableRules.speed(level + 1))
			local unlocks = TableRules.unlocksAt(level + 1)
			if #unlocks > 0 then
				local names = {}
				for _, recipeId in unlocks do
					table.insert(names, ItemKey.displayName(Recipes[recipeId].Output))
				end
				text ..= "\n" .. string.format(UIText.TableUnlocks, table.concat(names, ", "))
			end
			return text
		end),
		HotbarItems = computed(function(use)
			return PlayerView.hotbarItems(use(raw.Inventory), use(raw.Hotbar))
		end),
		InventoryBagText = computed(function(use)
			return string.format(
				UIText.InventoryBag,
				use(raw.BagLevel),
				Format.number(use(bagUsed)),
				Format.number(use(bagCapacity))
			)
		end),
	}
end

return PlayerView
