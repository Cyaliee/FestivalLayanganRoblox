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
	Shop = icon("Shop"),
	Inventory = icon("Inv"),
	Settings = icon("Set"),
	Info = icon("Info"),
	-- Tombol panah (sidebar & hotbar toggle)
	ArrowLeft = icon("<"),
	ArrowRight = icon(">"),
	ArrowDown = icon("v"),
	ArrowUp = icon("^"),
	Close = icon("X"),
	-- Umum
	Coin = icon("Rp"),
	Wallet = icon("Rp"),
	Bag = icon("Tas"),
	Upgrade = icon("Up"),
	Clock = icon("s"),
	Lock = icon("Lock"),
	Booster = icon("Emas"),
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
