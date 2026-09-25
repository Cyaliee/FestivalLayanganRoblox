--!strict
-- Semua teks yang tampil di UI.

return table.freeze({
	LevelShort = "Lv %d",
	ExpFormat = "%s / %s EXP",
	ExpMax = "MAX",
	BagFormat = "%d/%d",

	UpgradeTitle = "Meja Rakit",
	CurrentLevel = "Level Sekarang: %d",
	NextLevel = "Level Berikutnya: %d",
	MaxLevel = "Level Maksimal!",
	Cost = "Biaya: %s",
	CostUnknown = "-",
	UpgradeButton = "Upgrade",
	ComingSoon = "Segera Hadir",

	BagTitle = "Tas",
	BagLevel = "Tas Level %d",
	BagUsage = "Isi: %s / %s",
	BagNext = "Level %d: %s slot",
	BagMaxLevel = "Level Maksimal!",
	BagCost = "Harga: %s",
	BagUpgradeButton = "Upgrade",
	BagNotEnoughCoins = "Koin Kurang",

	ThousandSeparator = ".",
	-- Singkatan angka besar, dari terbesar
	CompactSuffixes = table.freeze({
		{ Value = 1e9, Suffix = "M" }, -- miliar
		{ Value = 1e6, Suffix = "jt" },
	}),
})
