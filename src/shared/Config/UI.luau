--!strict
-- Perilaku UI (bukan tampilan; tampilan ada di UITheme).

return table.freeze({
	NotificationDuration = 2.5, -- detik
	AnnouncementDuration = 5, -- detik per pengumuman global
	-- ScreenGui yang bisa dibuka server lewat bridge OpenUI. Tambah di fase berikutnya.
	OpenableScreens = table.freeze({
		UpgradeUI = true,
		BagUI = true,
		CraftUI = true,
		-- Shop_<Id> ditambahkan otomatis dari Config/Shops
	}),
})
