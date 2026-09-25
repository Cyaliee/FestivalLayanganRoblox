--!strict
--[[
	Gamepass. Isi Id dari Creator Dashboard. Id = 0 -> gamepass dianggap tidak ada (efek mati).
	Efek MENUMPUK dengan dikali (VIP + X2 EXP = 4x EXP).
	Luck: mengalikan peluang rarity (selain Common) & peluang Bambu Emas.
]]

export type Pass = { Id: number, DisplayName: string, ExpMultiplier: number?, LuckMultiplier: number? }

local Passes: { [string]: Pass } = {
	VIP = { Id = 0, DisplayName = "VIP", ExpMultiplier = 2, LuckMultiplier = 2 },
	X2Exp = { Id = 0, DisplayName = "X2 EXP", ExpMultiplier = 2 },
	Luck2 = { Id = 0, DisplayName = "Luck X2", LuckMultiplier = 2 },
}

return table.freeze({
	Passes = Passes,
	-- Attribute di Player (dibaca client, mis. untuk menampilkan peluang)
	ExpAttribute = "ExpMultiplier",
	LuckAttribute = "LuckMultiplier",
})
