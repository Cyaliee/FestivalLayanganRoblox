--!strict
-- Nama bridge BridgeNet2 & rate limit semua aksi pemain.

return table.freeze({
	Bridges = table.freeze({
		Notify = "Notify", -- server -> client: { Text: string }
		OpenUI = "OpenUI", -- server -> client: { Name: string }
		PlayerState = "PlayerState", -- server -> client: snapshot data pemain
		RequestState = "RequestState", -- client -> server: minta snapshot ulang (tanpa data)
		RequestBagUpgrade = "RequestBagUpgrade", -- client -> server: intent naik level tas (tanpa data)
		RequestEquip = "RequestEquip", -- client -> server: { Id: string? } pilih slot hotbar (Axe / layangan / kosong)
		RequestChop = "RequestChop", -- client -> server: ayun kapak (tanpa data; server cari pohon terdekat)
		RequestTrade = "RequestTrade", -- client -> server: { ShopId, ItemKey, Mode: "One"|"Bulk"|"All" }
		RequestCraft = "RequestCraft", -- client -> server: { RecipeId, UseBooster: boolean }
		RequestTableUpgrade = "RequestTableUpgrade", -- client -> server: intent upgrade meja (tanpa data)
		Announce = "Announce", -- server -> semua client: { Text: string, Palette: string? } pengumuman global
	}),

	-- Rate limit per pemain: maksimal <Max> aksi per <Window> detik.
	RateLimits = table.freeze({
		PlotPrompt = table.freeze({ Max = 3, Window = 2 }),
		RequestState = table.freeze({ Max = 3, Window = 5 }),
		BagUpgrade = table.freeze({ Max = 3, Window = 2 }),
		Equip = table.freeze({ Max = 8, Window = 2 }),
		Trade = table.freeze({ Max = 8, Window = 2 }),
		Craft = table.freeze({ Max = 3, Window = 2 }),
		TableUpgrade = table.freeze({ Max = 3, Window = 2 }),
		ShopPrompt = table.freeze({ Max = 3, Window = 2 }),
		CraftPrompt = table.freeze({ Max = 3, Window = 2 }),
		DragonPrompt = table.freeze({ Max = 2, Window = 2 }),
	}),

	-- Seberapa sering server cek perubahan data untuk dikirim ke client (detik)
	ReplicationInterval = 0.1,
})
