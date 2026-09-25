--!strict
--[[
	Resep crafting (data-driven). Tambah resep baru cukup di tabel ini.
	- Inputs dikurangi di server saat mulai merakit.
	- Output dengan HasRarity: rarity diacak saat selesai (Config/Rarity), kecuali FixedRarity diisi.
	- Booster (opsional): bahan tambahan yang dipilih pemain untuk menaikkan peluang rarity.
	- Duration dibagi kecepatan meja (Config/CraftingTable) dan dipotong Aura Naga (Config/Dragon).
	- RequiredTableLevel = "max" -> butuh Meja Rakit level maksimal.
]]

export type Recipe = {
	Id: string,
	Output: string,
	OutputAmount: number,
	Inputs: { [string]: number },
	Booster: { [string]: number }?,
	FixedRarity: string?,
	Duration: number,
	RequiredTableLevel: number | "max",
	Exp: number,
	Order: number,
}

local Recipes: { [string]: Recipe } = {
	Kite = {
		Id = "Kite",
		Output = "Kite",
		OutputAmount = 1,
		Inputs = { Bamboo = 1, Glue = 1, Paper = 1 },
		Booster = { GoldenBamboo = 1 },
		Duration = 5,
		RequiredTableLevel = 1,
		Exp = 5,
		Order = 1,
	},
	Naga = {
		Id = "Naga",
		Output = "Naga",
		OutputAmount = 1,
		Inputs = { GoldenBamboo = 3, ParachuteCloth = 10, SuperGlue = 5 },
		FixedRarity = "Mythic",
		Duration = 90,
		RequiredTableLevel = "max",
		Exp = 250,
		Order = 2,
	},
}

return Recipes
