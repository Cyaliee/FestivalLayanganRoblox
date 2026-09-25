local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local ShopUI = require(UI.Screens.ShopUI)

local controls = {
	OwnVIP = false,
	PriceVIP = 199,
	PriceX2Exp = 99,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local window = ShopUI(scope, {
			Open = scope:Value(true),
			OnClose = function() end,
			Owned = scope:Computed(function(use)
				return { VIP = use(c.OwnVIP) }
			end),
			Prices = scope:Computed(function(use)
				return { VIP = use(c.PriceVIP), X2Exp = use(c.PriceX2Exp) }
			end),
			OnBuy = function(key)
				print("[Story] Beli gamepass", key)
			end,
		})
		window.Parent = props.target
	end,
}
