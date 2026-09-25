--!strict
--[[
	Tingkat kelangkaan layangan. Diacak di server saat crafting selesai.
	Weight = peluang relatif (tidak harus berjumlah 100). Weight 0 = tidak bisa didapat dari acakan.
	Multiplier = pengali reward terbang & harga jual.
	Luck (gamepass) mengalikan Weight semua tier KECUALI LuckExcluded.
]]

export type Tier = {
	Id: string,
	DisplayName: string,
	Weight: number,
	BoostedWeight: number, -- peluang saat pakai Bambu Emas sebagai booster
	Multiplier: number,
	Palette: string, -- warna slot/label (UITheme.Palettes)
	Color: Color3, -- warna layangan placeholder & teks
	Rank: number,
}

local Tiers: { [string]: Tier } = {
	Common = {
		Id = "Common",
		DisplayName = "Common",
		Weight = 70,
		BoostedWeight = 30,
		Multiplier = 1,
		Palette = "Slot",
		Color = Color3.fromRGB(235, 235, 235),
		Rank = 1,
	},
	Uncommon = {
		Id = "Uncommon",
		DisplayName = "Uncommon",
		Weight = 20,
		BoostedWeight = 25,
		Multiplier = 1.5,
		Palette = "Green",
		Color = Color3.fromRGB(80, 225, 61),
		Rank = 2,
	},
	Rare = {
		Id = "Rare",
		DisplayName = "Rare",
		Weight = 8,
		BoostedWeight = 20,
		Multiplier = 2,
		Palette = "Blue",
		Color = Color3.fromRGB(24, 143, 255),
		Rank = 3,
	},
	Epic = {
		Id = "Epic",
		DisplayName = "Epic",
		Weight = 1.9,
		BoostedWeight = 10,
		Multiplier = 3,
		Palette = "Purple",
		Color = Color3.fromRGB(165, 108, 255),
		Rank = 4,
	},
	Legendary = {
		Id = "Legendary",
		DisplayName = "Legendary",
		Weight = 0.1,
		BoostedWeight = 15,
		Multiplier = 5,
		Palette = "Gold",
		Color = Color3.fromRGB(255, 179, 49),
		Rank = 5,
	},
	Mythic = {
		Id = "Mythic",
		DisplayName = "Mythic",
		Weight = 0, -- khusus Layangan Naga (resep tetap)
		BoostedWeight = 0,
		Multiplier = 10,
		Palette = "Red",
		Color = Color3.fromRGB(255, 53, 67),
		Rank = 6,
	},
}

-- Urutan dari paling umum
local Order = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }

return table.freeze({
	Tiers = Tiers,
	Order = Order,
	LuckExcluded = table.freeze({ Common = true }),
	-- Rarity yang layak diumumkan ke semua pemain saat dirakit
	AnnounceFrom = "Legendary",
})
