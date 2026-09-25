--!strict
-- Angka-angka tampilan UI (bukan layout; layout ada di Studio).

return table.freeze({
	NotificationDuration = 2.5, -- detik
	-- Nama ScreenGui di StarterGui yang bisa dibuka lewat bridge OpenUI
	OpenableScreens = table.freeze({
		UpgradeUI = true,
		ShopUI = true,
		SellUI = true,
		CraftUI = true,
	}),
})
