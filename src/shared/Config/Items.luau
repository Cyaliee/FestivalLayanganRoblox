--!strict
--[[
	Daftar semua item. Id = nama dasar item.
	Item dengan HasRarity = true disimpan per rarity di Inventory dengan key "<Id>@<Rarity>"
	(lihat Rules/ItemKey). Item lain disimpan dengan key = Id.
]]

export type ItemDef = {
	Id: string,
	DisplayName: string,
	Category: "Material" | "Kite" | "Dragon",
	CountsToBag: boolean, -- menghitung ke kapasitas tas
	HasRarity: boolean,
	Order: number, -- urutan tampil (hotbar/list)
}

local Items: { [string]: ItemDef } = {
	Bamboo = {
		Id = "Bamboo",
		DisplayName = "Bambu",
		Category = "Material",
		CountsToBag = true,
		HasRarity = false,
		Order = 1,
	},
	GoldenBamboo = {
		Id = "GoldenBamboo",
		DisplayName = "Bambu Emas",
		Category = "Material",
		CountsToBag = true,
		HasRarity = false,
		Order = 2,
	},
	Glue = { Id = "Glue", DisplayName = "Lem", Category = "Material", CountsToBag = true, HasRarity = false, Order = 3 },
	Paper = {
		Id = "Paper",
		DisplayName = "Kertas",
		Category = "Material",
		CountsToBag = true,
		HasRarity = false,
		Order = 4,
	},
	SuperGlue = {
		Id = "SuperGlue",
		DisplayName = "Lem Super",
		Category = "Material",
		CountsToBag = true,
		HasRarity = false,
		Order = 5,
	},
	ParachuteCloth = {
		Id = "ParachuteCloth",
		DisplayName = "Kain Parasut",
		Category = "Material",
		CountsToBag = true,
		HasRarity = false,
		Order = 6,
	},
	Kite = { Id = "Kite", DisplayName = "Layangan", Category = "Kite", CountsToBag = true, HasRarity = true, Order = 10 },
	Naga = {
		Id = "Naga",
		DisplayName = "Layangan Naga",
		Category = "Dragon",
		CountsToBag = true,
		HasRarity = true,
		Order = 20,
	},
}

return table.freeze(Items)
