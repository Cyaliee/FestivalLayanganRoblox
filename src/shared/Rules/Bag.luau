--!strict
-- Aturan kapasitas tas (dipakai server untuk validasi & client untuk tampilan).
local Items = require(script.Parent.Parent.Config.Items)
local Bags = require(script.Parent.Parent.Config.Bags)

local Bag = {}

-- Total item fisik yang menghitung ke kapasitas tas
function Bag.used(inventory: { [string]: number }): number
	local total = 0
	for id, count in inventory do
		local def = Items[id]
		if def and def.CountsToBag then
			total += count
		end
	end
	return total
end

function Bag.capacity(tier: number): number
	local def = Bags.Tiers[tier] or Bags.Tiers[1]
	return def.Capacity
end

-- Jumlah semua item dalam satu kategori (mis. "Kite")
function Bag.countCategory(inventory: { [string]: number }, category: string): number
	local total = 0
	for id, count in inventory do
		local def = Items[id]
		if def and def.Category == category then
			total += count
		end
	end
	return total
end

return Bag
