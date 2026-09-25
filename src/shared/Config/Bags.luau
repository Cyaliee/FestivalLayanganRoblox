--!strict
--[[
	Tas pemain: satu jenis "Tas", naik level 1, 2, 3, ... sampai MaxLevel.
	Kapasitas & harga dihitung dari rumus di bawah (lihat Rules/Bag.luau):
	  Kapasitas(level)      = bulatkan ke CapacityRound( CapacityBase * CapacityGrowth^(level-1) )
	  Harga(level -> +1)    = bulatkan ke PriceRound( PriceBase * PriceGrowth^(level-1) )
	Mau angka spesifik di level tertentu? Isi Overrides.
]]

return table.freeze({
	DisplayName = "Tas",
	MaxLevel = 20,

	CapacityBase = 20,
	CapacityGrowth = 1.25,
	CapacityRound = 5,

	PriceBase = 250,
	PriceGrowth = 1.6,
	PriceRound = 10,

	-- Contoh: [3] = { Capacity = 40, Price = 1000 }  (Price = harga naik dari level ini ke berikutnya)
	Overrides = table.freeze({} :: { [number]: { Capacity: number?, Price: number? } }),

	-- Jeda minimal antar notifikasi "Tas Penuh!" per pemain (detik), supaya tidak spam
	FullNotifyCooldown = 1.5,
})
