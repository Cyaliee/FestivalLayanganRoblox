--!strict
-- Konfigurasi DataStore & nilai awal data pemain.
local Items = require(script.Parent.Items)

local PlayerData = {}

-- Ganti suffix versi kalau mau reset semua data (mis. saat testing).
PlayerData.StoreName = "PlayerData_v1"

-- Nilai awal pemain baru
PlayerData.StartingCoins = 0
PlayerData.StartingLevel = 1
PlayerData.StartingExp = 0
PlayerData.StartingBagLevel = 1 -- level tas awal (lihat Config/Bags)
PlayerData.StartingTableLevel = 1

export type Data = {
	Coins: number,
	Level: number,
	Exp: number,
	BagLevel: number,
	TableLevel: number,
	Inventory: { [string]: number },
	-- Crafting yang sedang berjalan (nil kalau meja kosong). EndsAt = waktu server (GetServerTimeNow)
	ActiveCraft: { RecipeId: string, EndsAt: number }?,
}

-- Template ProfileStore. Reconcile() akan mengisi key baru untuk pemain lama.
function PlayerData.buildTemplate(): Data
	local inventory = {}
	for id in Items do
		inventory[id] = 0
	end
	return {
		Coins = PlayerData.StartingCoins,
		Level = PlayerData.StartingLevel,
		Exp = PlayerData.StartingExp,
		BagLevel = PlayerData.StartingBagLevel,
		TableLevel = PlayerData.StartingTableLevel,
		Inventory = inventory,
	}
end

return PlayerData
