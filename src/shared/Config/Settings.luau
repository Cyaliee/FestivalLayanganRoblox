--!strict
--[[
	Pengaturan pemain (disimpan di data, diubah lewat jendela Setting).
	Toggle = on/off. Choice = pilih salah satu dari Options.
]]

export type Setting = {
	Key: string,
	Label: string,
	Type: "Toggle" | "Choice",
	Default: any,
	Options: { string }?,
	Order: number,
}

local Settings: { [string]: Setting } = {
	ShowNametags = { Key = "ShowNametags", Label = "Tampilkan Nametag", Type = "Toggle", Default = true, Order = 1 },
	Music = { Key = "Music", Label = "Musik", Type = "Toggle", Default = true, Order = 2 },
	UIScale = {
		Key = "UIScale",
		Label = "Ukuran UI",
		Type = "Choice",
		Default = "Normal",
		Options = { "Kecil", "Normal", "Besar" },
		Order = 3,
	},
}

return table.freeze({
	Settings = Settings,
	-- Pengali skala UI untuk tiap pilihan UIScale
	UIScaleValues = table.freeze({ Kecil = 0.85, Normal = 1, Besar = 1.15 }),
	-- Musik latar: Sound bernama ini di SoundService (opsional, dibuat sendiri di Studio)
	MusicSoundName = "Music",
	MusicVolume = 0.4,
})
