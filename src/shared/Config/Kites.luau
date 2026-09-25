--!strict
--[[
	Layangan terbang di Area Festival (dari hotbar).
	Menerbangkan menghabiskan 1 layangan (sink). Tiap TickInterval detik pemain yang berada di
	Area Festival dapat koin & EXP = nilai dasar x Multiplier rarity (Config/Rarity).
]]

export type KiteStats = {
	Duration: number,
	TickInterval: number,
	ExpPerTick: number,
	CoinsPerTick: number,
	Size: Vector3, -- ukuran placeholder
}

local Stats: { [string]: KiteStats } = {
	Kite = {
		Duration = 60,
		TickInterval = 10,
		ExpPerTick = 2,
		CoinsPerTick = 5,
		Size = Vector3.new(4, 4, 0.2),
	},
}

return table.freeze({
	Stats = Stats,
	-- Skala ukuran visual per rarity
	RaritySize = table.freeze({ Legendary = 1.3 }),
	Height = 28, -- tinggi layangan di atas pemain (studs)
	Distance = 14, -- jarak ke belakang pemain
	SwayAmount = 3,
	SwaySpeed = 1.2,
	-- Attribute di Player (dibaca HUD client)
	KiteAttribute = "FlyingKite", -- item key, mis. "Kite@Epic"
	EndsAtAttribute = "FlightEndsAt",
	DurationAttribute = "FlightDuration",
})
