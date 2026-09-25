--!strict
-- Daftar semua item fisik. Id = key di Inventory pemain.
-- Tambah item baru cukup di sini; Inventory default dibangun otomatis dari tabel ini.

export type ItemDef = {
	Id: string,
	DisplayName: string,
	Category: "Material" | "Kite",
	-- true = menghitung ke kapasitas tas (dipakai di Fase 3)
	CountsToBag: boolean,
	-- Urutan tampil (hotbar/list)
	Order: number,
}

local Items: { [string]: ItemDef } = {
	Bamboo = { Id = "Bamboo", DisplayName = "Bambu", Category = "Material", CountsToBag = true, Order = 1 },
	Glue = { Id = "Glue", DisplayName = "Lem", Category = "Material", CountsToBag = true, Order = 2 },
	Paper = { Id = "Paper", DisplayName = "Kertas", Category = "Material", CountsToBag = true, Order = 3 },
	Cloth = { Id = "Cloth", DisplayName = "Kain", Category = "Material", CountsToBag = true, Order = 4 },
	KiteBiasa = { Id = "KiteBiasa", DisplayName = "Layangan Biasa", Category = "Kite", CountsToBag = true, Order = 10 },
	KiteNaga = { Id = "KiteNaga", DisplayName = "Layangan Naga", Category = "Kite", CountsToBag = true, Order = 11 },
}

return table.freeze(Items)
