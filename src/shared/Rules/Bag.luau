--!strict
-- Aturan tas (dipakai server untuk validasi & client untuk tampilan).
local Bags = require(script.Parent.Parent.Config.Bags)
local ItemKey = require(script.Parent.ItemKey)

local Bag = {}

local function roundTo(value: number, step: number): number
	return math.max(step, math.floor(value / step + 0.5) * step)
end

function Bag.clampLevel(level: number): number
	return math.clamp(math.floor(level), 1, Bags.MaxLevel)
end

-- Kapasitas tas di level tertentu
function Bag.capacity(level: number): number
	level = Bag.clampLevel(level)
	local override = Bags.Overrides[level]
	if override and override.Capacity then
		return override.Capacity
	end
	return roundTo(Bags.CapacityBase * Bags.CapacityGrowth ^ (level - 1), Bags.CapacityRound)
end

function Bag.isMaxLevel(level: number): boolean
	return level >= Bags.MaxLevel
end

-- Harga naik dari `level` ke `level + 1`. nil kalau sudah maksimal.
function Bag.upgradePrice(level: number): number?
	level = Bag.clampLevel(level)
	if Bag.isMaxLevel(level) then
		return nil
	end
	local override = Bags.Overrides[level]
	if override and override.Price then
		return override.Price
	end
	return roundTo(Bags.PriceBase * Bags.PriceGrowth ^ (level - 1), Bags.PriceRound)
end

-- Total item fisik yang menghitung ke kapasitas tas
function Bag.used(inventory: { [string]: number }): number
	local total = 0
	for key, count in inventory do
		local def = ItemKey.def(key)
		if def and def.CountsToBag then
			total += count
		end
	end
	return total
end

-- Jumlah semua item dalam satu kategori (mis. "Kite")
function Bag.countCategory(inventory: { [string]: number }, category: string): number
	local total = 0
	for key, count in inventory do
		local def = ItemKey.def(key)
		if def and def.Category == category then
			total += count
		end
	end
	return total
end

return Bag
