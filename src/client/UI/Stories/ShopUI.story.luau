local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ShopsConfig = require(ReplicatedStorage.Shared.Config.Shops)
local ShopUI = require(script.Parent.Parent.Screens.ShopUI)

local controls = {
	ShopId = "Toko", -- Pengepul / Toko / Tengkulak (reload story setelah ganti)
	Coins = 50,
	Bamboo = 12,
	Glue = 2,
	KiteBiasa = 3,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local shop = ShopsConfig.Shops[Fusion.peek(c.ShopId)] or ShopsConfig.Shops.Toko
		local open = scope:Value(true)

		local window = ShopUI(scope, {
			Shop = shop,
			Open = open,
			OnClose = function()
				open:set(false)
			end,
			Inventory = scope:Computed(function(use)
				return { Bamboo = use(c.Bamboo), Glue = use(c.Glue), KiteBiasa = use(c.KiteBiasa) }
			end),
			Coins = c.Coins,
			OnTrade = function(itemId, mode)
				print("[Story] Trade", shop.Id, itemId, mode)
			end,
		})
		window.Parent = props.target
	end,
}
