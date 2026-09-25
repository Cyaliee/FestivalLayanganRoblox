--!strict
-- Semua teks yang tampil di UI (tanpa emoji; ikon memakai gambar dari UIAssets).

return table.freeze({
	LevelShort = "Lv %d",
	LevelCard = "Lv. %d",
	ExpShort = "%s / %s",
	CoinFormat = "Rp. %s",
	Nametag = "%s | Lv.%d",
	ExpFormat = "%s / %s EXP",
	ExpMax = "MAX",
	BagFormat = "%d/%d",

	-- Sidebar
	SidebarShop = "Shop",
	SidebarInventory = "Inventory",
	SidebarSettings = "Setting",
	SidebarInfo = "Information",

	-- Inventory
	InventoryTitle = "Inventory",
	InventoryBag = "Tas Lv.%d  %s / %s",
	InventoryEmpty = "Tas kosong. Tebang bambu atau beli bahan di Pasar!",
	InventoryHint = "Klik item untuk pasang / lepas dari hotbar",

	-- Gamepass shop
	ShopTitle = "SHOP",
	ShopOwned = "Dimiliki",
	ShopUnavailable = "Segera",
	ShopRobux = "R$ %s",

	-- Meja Rakit
	UpgradeTitle = "MEJA RAKIT",
	CurrentLevel = "Level Sekarang: %d",
	NextLevel = "Level Berikutnya: %d",
	MaxLevel = "Level Maksimal",
	Cost = "Biaya: %s",
	CostUnknown = "-",
	UpgradeButton = "UPGRADE",

	-- Tas
	BagTitle = "TAS",
	BagLevel = "Tas Level %d",
	BagUsage = "Isi: %s / %s",
	BagNext = "Level %d: %s slot",
	BagMaxLevel = "Level Maksimal",
	BagCost = "Harga: %s",
	BagUpgradeButton = "UPGRADE",
	BagNotEnoughCoins = "UANG KURANG",

	TableSpeed = "Kecepatan rakit x%g",
	TableSpeedNext = "Kecepatan rakit x%g -> x%g",
	TableUnlocks = "Membuka: %s",

	-- Pasar
	Price = "%s",
	Owned = "Punya: %s",
	BuyOne = "BELI 1",
	BuyBulk = "BELI %d",
	SellOne = "JUAL 1",
	SellAll = "JUAL SEMUA",

	-- Crafting
	CraftTitle = "RAKIT LAYANGAN",
	CraftButton = "RAKIT",
	BoosterOn = "BAMBU EMAS: ON",
	BoosterOff = "BAMBU EMAS: OFF",
	FixedRarity = "Selalu %s",
	LegendaryChance = "Peluang Legendary: %s%%",
	CraftBusy = "Merakit %s - %s",
	CraftReady = "%s siap! (tas penuh?)",
	CraftIdle = "Meja siap dipakai",
	CraftLocked = "MEJA LV %d",
	CraftDuration = "%ss",
	Requirement = "%d %s (%s)",
	Seconds = "%ds",
	Done = "Selesai!",

	-- Setting
	SettingsTitle = "SETTING",
	On = "ON",
	Off = "OFF",

	-- Layangan terbang
	FlightText = "%s - %s",

	ThousandSeparator = ".",
	-- Singkatan angka besar, dari terbesar
	CompactSuffixes = table.freeze({
		{ Value = 1e9, Suffix = "M" }, -- miliar
		{ Value = 1e6, Suffix = "jt" },
	}),
})
