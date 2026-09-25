--!strict
-- Nama bridge BridgeNet2 & rate limit semua aksi pemain.

return table.freeze({
	Bridges = table.freeze({
		Notify = "Notify", -- server -> client: { Text: string }
		OpenUI = "OpenUI", -- server -> client: { Name: string }
		PlayerState = "PlayerState", -- server -> client: snapshot data pemain
		RequestState = "RequestState", -- client -> server: minta snapshot ulang (tanpa data)
		RequestBagUpgrade = "RequestBagUpgrade", -- client -> server: intent naik level tas (tanpa data)
	}),

	-- Rate limit per pemain: maksimal <Max> aksi per <Window> detik.
	RateLimits = table.freeze({
		PlotPrompt = table.freeze({ Max = 3, Window = 2 }),
		RequestState = table.freeze({ Max = 3, Window = 5 }),
		BagUpgrade = table.freeze({ Max = 3, Window = 2 }),
	}),

	-- Seberapa sering server cek perubahan data untuk dikirim ke client (detik)
	ReplicationInterval = 0.1,
})
