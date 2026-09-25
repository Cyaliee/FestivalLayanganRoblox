--!strict
-- Konfigurasi kavling. Nama instance harus cocok dengan yang ada di Studio (lihat UI_CONTRACT.md).

return table.freeze({
	-- Workspace/<FolderName>/<Plot model>
	FolderName = "Plots",
	-- Anak dari tiap plot model
	SignName = "PapanNama", -- BasePart atau Model
	PromptName = "PlotPrompt", -- ProximityPrompt di dalam PapanNama (dibuat otomatis kalau tidak ada)
	OwnerTextName = "OwnerText", -- TextLabel di SurfaceGui PapanNama (opsional)
	TableSpawnName = "TableSpawn", -- Part penanda posisi MejaRakit

	-- ServerStorage/<AssetFolder>/<TableAssetName>
	AssetFolder = "Assets",
	TableAssetName = "MejaRakit",
	-- Nama clone meja di dalam plot
	SpawnedTableName = "MejaRakit",

	-- ProximityPrompt
	ClaimActionText = "Klaim Kavling",
	OwnedActionText = "Upgrade Meja",
	ObjectText = "Papan Nama",
	HoldDuration = 0.5,
	MaxActivationDistance = 10,
	-- Toleransi ekstra (studs) untuk validasi jarak di server (lag/latency)
	DistanceTolerance = 6,

	-- Teks papan nama
	EmptyOwnerText = "Kavling Kosong",
	OwnerTextFormat = "Kavling %s",

	-- Attribute yang di-set server pada plot model (dibaca client)
	OwnerAttribute = "OwnerUserId",
})
