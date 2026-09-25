--!strict
--[[
	Toko & pengepul di Pasar. Harga HANYA dari sini (server memakai tabel yang sama).
	Type "Sell" = pemain menjual ke NPC, "Buy" = pemain membeli dari NPC.
	NpcName = nama Model NPC di Workspace/Pasar.
]]

export type ShopItem = { ItemId: string, Price: number, Order: number }
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
			{ ItemId = "Bamboo", Price = 5, Order = 1 },
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
			{ ItemId = "Glue", Price = 8, Order = 1 },
			{ ItemId = "Paper", Price = 6, Order = 2 },
			{ ItemId = "Cloth", Price = 20, Order = 3 },
		},
	},
	Tengkulak = {
		Id = "Tengkulak",
		Type = "Sell",
		Title = "Tengkulak Layangan",
		NpcName = "Tengkulak",
		PromptText = "Jual Layangan",
		Palette = "Red",
		Items = {
			{ ItemId = "KiteBiasa", Price = 40, Order = 1 },
			{ ItemId = "KiteNaga", Price = 250, Order = 2 },
		},
	},
}

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

function ShopsConfig.findItem(shop: Shop, itemId: string): ShopItem?
	for _, entry in shop.Items do
		if entry.ItemId == itemId then
			return entry
		end
	end
	return nil
end

return ShopsConfig
