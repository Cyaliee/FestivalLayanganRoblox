--!strict
-- Nama bridge BridgeNet2 & rate limit semua aksi pemain.

return table.freeze({
	Bridges = table.freeze({
		Notify = "Notify", -- server -> client: { Text: string }
		OpenUI = "OpenUI", -- server -> client: { Name: string }
	}),

	-- Rate limit per pemain: maksimal <Max> aksi per <Window> detik.
	RateLimits = table.freeze({
		PlotPrompt = table.freeze({ Max = 3, Window = 2 }),
	}),
})
