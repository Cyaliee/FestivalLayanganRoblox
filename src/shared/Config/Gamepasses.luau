--!strict
--[[
	Gamepass. Isi Id dari Creator Dashboard. Id = 0 -> gamepass dianggap tidak ada (efek mati).
	Efek MENUMPUK dengan dikali (VIP + X2 EXP = 4x EXP).
	Luck: mengalikan peluang rarity (selain Common) & peluang Bambu Emas.
]]

export type Pass = {
	Id: number,
	DisplayName: string,
	Description: string,
	ExpMultiplier: number?,
	LuckMultiplier: number?,
	Order: number,
}

local Passes: { [string]: Pass } = {
	VIP = {
		Id = 0,
		DisplayName = "VIP",
		Description = "2x EXP & 2x Luck",
		ExpMultiplier = 2,
		LuckMultiplier = 2,
		Order = 1,
	},
	X2Exp = { Id = 0, DisplayName = "X2 EXP", Description = "EXP dua kali lipat", ExpMultiplier = 2, Order = 2 },
	Luck2 = { Id = 0, DisplayName = "LUCK X2", Description = "Peluang rarity & Bambu Emas 2x", LuckMultiplier = 2, Order = 3 },
}

return table.freeze({
	Passes = Passes,
	-- Attribute di Player (dibaca client, mis. untuk menampilkan peluang)
	ExpAttribute = "ExpMultiplier",
	LuckAttribute = "LuckMultiplier",
	OwnedAttributePrefix = "Pass_",
})
