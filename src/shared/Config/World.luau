--!strict
-- Nama folder/instance dunia yang disiapkan di Studio (lihat SETUP_STUDIO.md).

return table.freeze({
	-- Workspace
	BambooFolder = "HutanBambu", -- berisi Model pohon bambu
	MarketFolder = "Pasar", -- berisi Model NPC (nama sesuai Config/Shops NpcName)
	FestivalAreaName = "AreaFestival", -- Part (atau Folder berisi Part) penanda area terbang
	FlyingKitesFolder = "LayanganTerbang", -- dibuat otomatis

	-- ServerStorage
	FelledTreesFolder = "PohonTumbang", -- dibuat otomatis (tempat pohon yang sedang ditebang)
	AssetFolder = "Assets",
	ToolsFolder = "Tools", -- ServerStorage/Assets/Tools/<nama tool>
	KitesFolder = "Kites", -- ServerStorage/Assets/Kites/<ItemId>  (opsional)
})
