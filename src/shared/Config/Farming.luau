--!strict
-- Hutan bambu & kapak.

return table.freeze({
	Bamboo = table.freeze({
		MaxHp = 3, -- jumlah ayunan kapak sampai tumbang
		YieldItem = "Bamboo",
		YieldAmount = 2,
		RespawnTime = 15, -- detik
		ExpPerFell = 2,
		HpAttribute = "HP",
		MaxHpAttribute = "MaxHP",
	}),

	Axe = table.freeze({
		HotbarId = "Axe", -- id slot hotbar (ikon di UIAssets.Items.Axe)
		ToolName = "Kapak", -- nama Tool di ServerStorage/Assets/Tools
		Damage = 1,
		Range = 12, -- studs dari karakter ke pohon
		SwingCooldown = 0.45, -- detik antar ayunan
	}),
})
