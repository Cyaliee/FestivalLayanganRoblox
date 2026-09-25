--!strict
--[[
	Layangan terbang di Area Festival.
	Menerbangkan menghabiskan 1 layangan (sink). Selama Duration, tiap TickInterval detik
	pemain yang berada di Area Festival dapat EXP & Koin.
]]

export type KiteStats = {
	Duration: number,
	TickInterval: number,
	ExpPerTick: number,
	CoinsPerTick: number,
	Color: Color3, -- warna layangan placeholder (kalau model tidak ada)
	Size: Vector3,
}

local Stats: { [string]: KiteStats } = {
	KiteBiasa = {
		Duration = 60,
		TickInterval = 2,
		ExpPerTick = 3,
		CoinsPerTick = 2,
		Color = Color3.fromRGB(255, 80, 80),
		Size = Vector3.new(4, 4, 0.2),
	},
	KiteNaga = {
		Duration = 120,
		TickInterval = 2,
		ExpPerTick = 10,
		CoinsPerTick = 8,
		Color = Color3.fromRGB(255, 180, 40),
		Size = Vector3.new(7, 7, 0.2),
	},
}

return table.freeze({
	Stats = Stats,
	Height = 28, -- tinggi layangan di atas pemain (studs)
	Distance = 14, -- jarak ke belakang pemain
	SwayAmount = 3, -- goyangan kiri-kanan
	SwaySpeed = 1.2,
	-- Attribute di Player (dibaca HUD client)
	KiteAttribute = "FlyingKite",
	EndsAtAttribute = "FlightEndsAt",
	DurationAttribute = "FlightDuration",
})
