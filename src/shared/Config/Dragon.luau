--!strict
--[[
	Layangan Naga (endgame). Dipasang di kavling (bukan dari hotbar), tanpa durasi,
	maksimal 1 per kavling, bisa diturunkan kembali ke inventory.
	Selama terpasang memancarkan Aura Buff.
]]

return table.freeze({
	ItemId = "Naga",

	-- Mesin AFK: pemilik cukup online di mana saja
	TickInterval = 10,
	CoinsPerTick = 100,
	ExpPerTick = 40,

	-- Aura
	CraftTimeMultiplier = 0.5, -- crafting di meja pemilik 50% lebih cepat
	SocialExpBonus = 0.25, -- pemain LAIN di dekat naga: +25% EXP
	AuraRadius = 45, -- studs dari pusat kavling (horizontal)

	-- Visual (model: ServerStorage/Assets/Kites/Naga_<Rarity> atau Naga; kalau tidak ada dipakai placeholder)
	Height = 140, -- tinggi di atas meja
	SwayAmount = 18,
	SwaySpeed = 0.35,
	PlaceholderSize = Vector3.new(30, 30, 2),
	PoleName = "TiangNaga", -- Part opsional di kavling; kalau tidak ada tali diikat ke meja

	-- Prompt di MejaRakit
	PromptName = "DragonPrompt",
	PlaceText = "Pasang Naga",
	LowerText = "Turunkan Naga",
	PromptKey = Enum.KeyCode.F,
	-- Attribute di model MejaRakit (dibaca client untuk menyembunyikan prompt)
	PlacedAttribute = "DragonPlaced",
})
