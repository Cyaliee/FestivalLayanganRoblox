--!strict
-- Konfigurasi DataStore & nilai awal data pemain.
local Items = require(script.Parent.Items)
local SettingsConfig = require(script.Parent.Settings)

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
	ActiveCraft: { RecipeId: string, EndsAt: number, Boosted: boolean? }?,
	-- Item key Layangan Naga yang sedang dipasang di kavling (nil = tidak ada)
	PlacedDragon: string?,
	-- Item key yang dipasang pemain ke hotbar (urut slot, setelah slot tool)
	Hotbar: { string },
	-- Pengaturan pemain (Config/Settings)
	Settings: { [string]: any },
}

-- Template ProfileStore. Reconcile() akan mengisi key baru untuk pemain lama.
function PlayerData.buildTemplate(): Data
	-- Hanya item tanpa rarity yang punya slot awal; item ber-rarity ("Kite@Epic") ditambah saat didapat
	local inventory = {}
	for id, def in Items do
		if not def.HasRarity then
			inventory[id] = 0
		end
	end
	local settings = {}
	for key, setting in SettingsConfig.Settings do
		settings[key] = setting.Default
	end
	return {
		Hotbar = {},
		Settings = settings,
		Coins = PlayerData.StartingCoins,
		Level = PlayerData.StartingLevel,
		Exp = PlayerData.StartingExp,
		BagLevel = PlayerData.StartingBagLevel,
		TableLevel = PlayerData.StartingTableLevel,
		Inventory = inventory,
	}
end

return PlayerData
