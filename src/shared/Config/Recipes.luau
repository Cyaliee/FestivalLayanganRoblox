--!strict
--[[
	Resep crafting (data-driven). Tambah resep baru cukup di tabel ini.
	Inputs dikurangi di server saat mulai merakit. Duration dibagi kecepatan meja (Config/CraftingTable).
]]

export type Recipe = {
	Id: string,
	Output: string,
	OutputAmount: number,
	Inputs: { [string]: number },
	Duration: number, -- detik di meja level 1
	RequiredTableLevel: number,
	Exp: number, -- EXP saat hasil diambil
	Order: number,
}

local Recipes: { [string]: Recipe } = {
	KiteBiasa = {
		Id = "KiteBiasa",
		Output = "KiteBiasa",
		OutputAmount = 1,
		Inputs = { Bamboo = 1, Glue = 1, Paper = 1 },
		Duration = 5,
		RequiredTableLevel = 1,
		Exp = 5,
		Order = 1,
	},
	KiteNaga = {
		Id = "KiteNaga",
		Output = "KiteNaga",
		OutputAmount = 1,
		Inputs = { Bamboo = 5, Cloth = 3 },
		Duration = 20,
		RequiredTableLevel = 3,
		Exp = 25,
		Order = 2,
	},
}

return Recipes
