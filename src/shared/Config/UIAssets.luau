--!strict
--[[
	GAMBAR UI — ISI DI SINI.
	Image  = asset id, mis. "rbxassetid://1234567890". Kosong ("") = pakai Fallback.
	Fallback = teks/emoji yang tampil selama Image masih kosong.

	Buttons: skin ImageButton per varian tombol. Kosong = tombol digambar kode
	(gradient + outline). Kalau diisi, gambar dipakai sebagai skin tombol dan
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
}

-- Ikon per item. Key = Id di Config/Items.
local Items: { [string]: IconAsset } = {
	Bamboo = { Image = "", Fallback = "🎋" },
	Glue = { Image = "", Fallback = "🧴" },
	Paper = { Image = "", Fallback = "📜" },
	Cloth = { Image = "", Fallback = "🧵" },
	KiteBiasa = { Image = "", Fallback = "🪁" },
	KiteNaga = { Image = "", Fallback = "🐉" },
}

-- Key = nama palette tombol di UITheme.Palettes (Primary, Secondary, Danger, Gold, Slot, ...)
local Buttons: { [string]: ButtonSkin } = {
	Primary = { Image = "" },
	Secondary = { Image = "" },
	Danger = { Image = "" },
	Gold = { Image = "" },
	Slot = { Image = "" },
	SlotEmpty = { Image = "" },
}

return table.freeze({
	Icons = table.freeze(Icons),
	Items = table.freeze(Items),
	Buttons = table.freeze(Buttons),
})
