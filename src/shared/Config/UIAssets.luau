--!strict
--[[
	GAMBAR UI - ISI DI SINI. Semua ikon memakai gambar (tidak ada emoji).
	Image = asset id, mis. "rbxassetid://1234567890".
	Label = teks singkat yang tampil SELAMA Image masih kosong (placeholder untuk testing).
]]

export type IconAsset = { Image: string, Label: string }

local function icon(label: string, image: string?): IconAsset
	return table.freeze({ Image = image or "", Label = label })
end

local Icons: { [string]: IconAsset } = {
	-- Sidebar
	Shop = icon("Shop", "rbxassetid://96765539210233"),
	Inventory = icon("Inv", "rbxassetid://94803830058788"),
	Settings = icon("Set", "rbxassetid://72356111318001"),
	Info = icon("Info", "rbxassetid://137886927286330"),
	-- Tombol panah (sidebar & hotbar toggle)
	ArrowLeft = icon("<", "rbxassetid://81346262937714"),
	ArrowRight = icon(">", "rbxassetid://81538393870915"),
	ArrowDown = icon("v", "rbxassetid://95589229542680"),
	ArrowUp = icon("^", "rbxassetid://95589229542680"),
	Close = icon("X", "rbxassetid://100108698877198"),
	-- Umum
	Coin = icon("Rp", "rbxassetid://73686977787804"),
	Wallet = icon("Rp", "rbxassetid://108077675842571"),
	Bag = icon("Tas", "rbxassetid://94803830058788"),
	Upgrade = icon("Up", "rbxassetid://123693986624013"),
	Clock = icon("s", "rbxassetid://95864835539413"),
	Lock = icon("Lock", "rbxassetid://89397223903966"),
	Booster = icon("Emas", "rbxassetid://124732414241856"),
}

-- Ikon per item. Key = Id di Config/Items (semua rarity pakai ikon yang sama, warna bingkai beda).
local Items: { [string]: IconAsset } = {
	Bamboo = icon("Bambu"),
	GoldenBamboo = icon("Emas"),
	Glue = icon("Lem"),
	SuperGlue = icon("Lem+"),
	Paper = icon("Kertas"),
	ParachuteCloth = icon("Kain"),
	Kite = icon("Layang"),
	Naga = icon("Naga"),
	Axe = icon("Kapak"), -- slot tool hotbar
}

-- Gambar kartu gamepass di Shop (key = Config/Gamepasses)
local Gamepasses: { [string]: IconAsset } = {
	VIP = icon("VIP"),
	X2Exp = icon("2x EXP"),
	Luck2 = icon("2x Luck"),
}

return table.freeze({
	Icons = table.freeze(Icons),
	Items = table.freeze(Items),
	Gamepasses = table.freeze(Gamepasses),
})
