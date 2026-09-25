--!strict
--[[
	Toko & pengepul di Pasar. Harga HANYA dari sini (server memakai tabel yang sama).
	Type "Sell" = pemain menjual ke NPC, "Buy" = pemain membeli dari NPC.
	NpcName = nama Model NPC di Workspace/Pasar.
]]

-- ItemKey = key inventory ("Bamboo", "Kite@Epic"). Price = harga final.
export type ShopItem = { ItemKey: string, Price: number, Order: number }
export type Shop = {
	Id: string,
	Type: "Buy" | "Sell",
	Title: string,
	NpcName: string,
	PromptText: string,
	Palette: string, -- warna jendela (UITheme)
	Items: { ShopItem },
}

local Shops: { [string]: Shop } = {
	Pengepul = {
		Id = "Pengepul",
		Type = "Sell",
		Title = "Pengepul Bambu",
		NpcName = "Pengepul",
		PromptText = "Jual Bambu",
		Palette = "Green",
		Items = {
			{ ItemKey = "Bamboo", Price = 5, Order = 1 },
		},
	},
	Toko = {
		Id = "Toko",
		Type = "Buy",
		Title = "Toko Bahan",
		NpcName = "Toko",
		PromptText = "Beli Bahan",
		Palette = "Blue",
		Items = {
			{ ItemKey = "Glue", Price = 8, Order = 1 },
			{ ItemKey = "Paper", Price = 6, Order = 2 },
			{ ItemKey = "SuperGlue", Price = 150, Order = 3 },
			{ ItemKey = "ParachuteCloth", Price = 120, Order = 4 },
		},
	},
	Tengkulak = {
		Id = "Tengkulak",
		Type = "Sell",
		Title = "Tengkulak Layangan",
		NpcName = "Tengkulak",
		PromptText = "Jual Layangan",
		Palette = "Red",
		Items = {}, -- diisi otomatis di bawah: Layangan per rarity
	},
}

-- Tengkulak: harga Layangan = KiteBasePrice x Multiplier rarity (Common..Legendary)
local KiteBasePrice = 40
do
	local Rarity = require(script.Parent.Rarity)
	for index, rarityId in Rarity.Order do
		local tier = Rarity.Tiers[rarityId]
		if tier.Weight > 0 then
			table.insert(Shops.Tengkulak.Items, {
				ItemKey = "Kite@" .. rarityId,
				Price = math.floor(KiteBasePrice * tier.Multiplier),
				Order = index,
			})
		end
	end
end

local ShopsConfig = {
	Shops = Shops,
	InteractDistance = 10, -- MaxActivationDistance prompt NPC
	DistanceTolerance = 8, -- toleransi validasi jarak di server
	BulkBuyAmount = 10, -- tombol "Beli 10"
	-- Mode transaksi yang boleh dikirim client (bukan jumlah!)
	Modes = table.freeze({ One = true, Bulk = true, All = true }),
}

-- Nama screen UI untuk shop tertentu
function ShopsConfig.screenName(shopId: string): string
	return "Shop_" .. shopId
end

function ShopsConfig.findItem(shop: Shop, itemKey: string): ShopItem?
	for _, entry in shop.Items do
		if entry.ItemKey == itemKey then
			return entry
		end
	end
	return nil
end

return ShopsConfig
