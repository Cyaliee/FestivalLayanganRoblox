--!strict
--[[
	GAMBAR UI — ISI DI SINI.
	Image  = asset id, mis. "rbxassetid://1234567890". Kosong ("") = pakai Fallback.
	Fallback = teks/emoji yang tampil selama Image masih kosong.

	Buttons: skin ImageButton per warna tombol (opsional). Kosong = tombol digambar kode
	(gaya Studded: warna solid + stud + outline + bayangan). Kalau diisi, gambar dipakai sebagai skin tombol dan
	SliceCenter (opsional) dipakai untuk 9-slice supaya tidak gepeng.
]]

export type IconAsset = { Image: string, Fallback: string }
export type ButtonSkin = { Image: string, SliceCenter: Rect? }

local Icons: { [string]: IconAsset } = {
	Coin = { Image = "", Fallback = "🪙" },
	Bamboo = { Image = "", Fallback = "🎋" },
	Kite = { Image = "", Fallback = "🪁" },
	Bag = { Image = "", Fallback = "🎒" },
	Close = { Image = "", Fallback = "✖" },
	Upgrade = { Image = "", Fallback = "⬆" },
	Clock = { Image = "", Fallback = "⏱" },
	Lock = { Image = "", Fallback = "🔒" },
}

-- Ikon per item. Key = Id di Config/Items.
local Items: { [string]: IconAsset } = {
	Bamboo = { Image = "", Fallback = "🎋" },
	Glue = { Image = "", Fallback = "🧴" },
	Paper = { Image = "", Fallback = "📜" },
	Cloth = { Image = "", Fallback = "🧵" },
	KiteBiasa = { Image = "", Fallback = "🪁" },
	KiteNaga = { Image = "", Fallback = "🐉" },
	Axe = { Image = "", Fallback = "🪓" }, -- slot tool hotbar
}

-- Key = nama palette di UITheme.Palettes (Green, Blue, Close, Orange, ...). Kosong = gaya Studded dari kode.
local Buttons: { [string]: ButtonSkin } = {}

return table.freeze({
	Icons = table.freeze(Icons),
	Items = table.freeze(Items),
	Buttons = table.freeze(Buttons),
})
