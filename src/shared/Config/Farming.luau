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

	-- Bambu Emas: tidak dijual di NPC mana pun
	Golden = table.freeze({
		ItemId = "GoldenBamboo",
		DropChance = 0.01, -- peluang per pohon tumbang (dikali Luck)
		-- Pohon emas acak di hutan
		SpawnInterval = 30 * 60, -- detik
		Lifetime = 10 * 60, -- hilang kalau tidak ditebang
		MaxHp = 12, -- lebih banyak ayunan, supaya pemain berkerumun
		YieldAmount = 3, -- Bambu Emas dari pohon emas (+ bambu biasa)
		Attribute = "Golden",
		Color = Color3.fromRGB(255, 200, 40),
	}),

	Axe = table.freeze({
		HotbarId = "Axe", -- id slot hotbar (ikon di UIAssets.Items.Axe)
		ToolName = "Kapak", -- nama Tool di ServerStorage/Assets/Tools
		Damage = 1,
		Range = 12, -- studs dari karakter ke pohon
		SwingCooldown = 0.45, -- detik antar ayunan
	}),
})
