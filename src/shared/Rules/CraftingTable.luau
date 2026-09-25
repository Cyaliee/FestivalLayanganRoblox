--!strict
-- Aturan Meja Rakit & crafting (dipakai server & client).
local TableConfig = require(script.Parent.Parent.Config.CraftingTable)
local Recipes = require(script.Parent.Parent.Config.Recipes)
local Dragon = require(script.Parent.Parent.Config.Dragon)

local CraftingTable = {}

function CraftingTable.clampLevel(level: number): number
	return math.clamp(math.floor(level), 1, TableConfig.MaxLevel)
end

function CraftingTable.speed(level: number): number
	return TableConfig.Levels[CraftingTable.clampLevel(level)].Speed
end

-- Biaya naik dari `level` ke `level + 1`. nil kalau sudah maksimal.
function CraftingTable.upgradeCost(level: number): number?
	return TableConfig.Levels[CraftingTable.clampLevel(level)].UpgradeCost
end

function CraftingTable.requiredLevel(recipeId: string): number
	local required = Recipes[recipeId].RequiredTableLevel
	return if required == "max" then TableConfig.MaxLevel else required :: number
end

-- Lama merakit (detik) di meja level tertentu; dragonActive = Aura Naga di kavling
function CraftingTable.craftDuration(recipeId: string, level: number, dragonActive: boolean?): number
	local recipe = Recipes[recipeId]
	local duration = recipe.Duration / CraftingTable.speed(level)
	if dragonActive then
		duration *= Dragon.CraftTimeMultiplier
	end
	return duration
end

-- Resep yang baru terbuka tepat di level ini
function CraftingTable.unlocksAt(level: number): { string }
	local list = {}
	for id in Recipes do
		if CraftingTable.requiredLevel(id) == level then
			table.insert(list, id)
		end
	end
	table.sort(list)
	return list
end

-- Semua bahan (Inputs + Booster kalau dipakai) sebagai satu tabel
function CraftingTable.cost(recipeId: string, useBooster: boolean): { [string]: number }
	local recipe = Recipes[recipeId]
	local cost = table.clone(recipe.Inputs)
	if useBooster and recipe.Booster then
		for itemId, amount in recipe.Booster do
			cost[itemId] = (cost[itemId] or 0) + amount
		end
	end
	return cost
end

function CraftingTable.hasMaterials(inventory: { [string]: number }, recipeId: string, useBooster: boolean?): boolean
	for itemId, amount in CraftingTable.cost(recipeId, useBooster == true) do
		if (inventory[itemId] or 0) < amount then
			return false
		end
	end
	return true
end

return CraftingTable
