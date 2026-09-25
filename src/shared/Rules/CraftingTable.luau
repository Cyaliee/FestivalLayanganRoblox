--!strict
-- Aturan Meja Rakit & crafting (dipakai server & client).
local TableConfig = require(script.Parent.Parent.Config.CraftingTable)
local Recipes = require(script.Parent.Parent.Config.Recipes)

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

-- Lama merakit (detik) di meja level tertentu
function CraftingTable.craftDuration(recipeId: string, level: number): number
	local recipe = Recipes[recipeId]
	return recipe.Duration / CraftingTable.speed(level)
end

-- Resep yang baru terbuka tepat di level ini
function CraftingTable.unlocksAt(level: number): { string }
	local list = {}
	for id, recipe in Recipes do
		if recipe.RequiredTableLevel == level then
			table.insert(list, id)
		end
	end
	table.sort(list)
	return list
end

function CraftingTable.hasMaterials(inventory: { [string]: number }, recipeId: string): boolean
	local recipe = Recipes[recipeId]
	for itemId, amount in recipe.Inputs do
		if (inventory[itemId] or 0) < amount then
			return false
		end
	end
	return true
end

return CraftingTable
