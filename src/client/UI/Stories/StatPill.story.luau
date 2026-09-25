local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local StatPill = require(script.Parent.Parent.Components.StatPill)

local controls = {
	Coins = 1250,
	Palette = "Coin", -- nama palette/role: Coin, Bamboo, Kite, Bag, BagFull, Red, Blue, ...
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local pill = StatPill(scope, {
			Icon = UIAssets.Icons.Coin,
			Text = scope:Computed(function(use)
				return Format.number(use(props.controls.Coins))
			end),
			Palette = props.controls.Palette,
			Position = UDim2.fromOffset(40, 40),
		})
		pill.Parent = props.target
	end,
}
