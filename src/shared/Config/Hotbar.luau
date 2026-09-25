--!strict
-- Hotbar custom (menggantikan Backpack bawaan Roblox).

return table.freeze({
	SlotCount = 9,
	-- Slot tetap di depan (tool), id sesuai UIAssets.Items
	Tools = table.freeze({ "Axe" }),
	-- Tombol keyboard per slot, urut dari slot 1
	KeyCodes = table.freeze({
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three,
		Enum.KeyCode.Four,
		Enum.KeyCode.Five,
		Enum.KeyCode.Six,
		Enum.KeyCode.Seven,
		Enum.KeyCode.Eight,
		Enum.KeyCode.Nine,
	}),
	DisableDefaultBackpack = true,
	-- Slot yang bisa diisi pemain dari Inventory = SlotCount - jumlah Tools
	-- Kategori yang boleh dipasang ke hotbar dari Inventory
	AssignableCategories = table.freeze({ Material = true, Kite = true }),
})
