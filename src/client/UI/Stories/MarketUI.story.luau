local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local ShopsConfig = require(ReplicatedStorage.Shared.Config.Shops)
local MarketUI = require(UI.Screens.MarketUI)

local controls = {
	ShopId = "Tengkulak", -- Pengepul / Toko / Tengkulak (reload story setelah ganti)
	Coins = 500,
	KiteCommon = 3,
	KiteLegendary = 1,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local shop = ShopsConfig.Shops[Fusion.peek(c.ShopId)] or ShopsConfig.Shops.Toko
		local window = MarketUI(scope, {
			Shop = shop,
			Open = scope:Value(true),
			OnClose = function() end,
			Inventory = scope:Computed(function(use)
				return { Bamboo = 10, ["Kite@Common"] = use(c.KiteCommon), ["Kite@Legendary"] = use(c.KiteLegendary) }
			end),
			Coins = c.Coins,
			OnTrade = function(itemKey, mode)
				print("[Story] Trade", shop.Id, itemKey, mode)
			end,
		})
		window.Parent = props.target
	end,
}
