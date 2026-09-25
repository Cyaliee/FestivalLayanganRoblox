--!strict
-- Tier tas. BagTier di data pemain = index ke Tiers.
-- Pembelian & penolakan loot saat penuh diterapkan di Fase 3.

export type BagTier = {
	Id: string,
	DisplayName: string,
	Capacity: number,
	Price: number,
}

local Tiers: { BagTier } = {
	{ Id = "Kresek", DisplayName = "Kresek", Capacity = 20, Price = 0 },
	{ Id = "KarungGoni", DisplayName = "Karung Goni", Capacity = 50, Price = 500 },
	{ Id = "Ransel", DisplayName = "Ransel", Capacity = 100, Price = 2500 },
	{ Id = "Kargo", DisplayName = "Kargo", Capacity = 250, Price = 10000 },
}

return table.freeze({
	Tiers = table.freeze(Tiers),
})
