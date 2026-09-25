local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local StatPill = require(script.Parent.Parent.Components.StatPill)

local controls = {
	Coins = 1250,
	Warning = false,
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
			Warning = props.controls.Warning,
			Position = UDim2.fromOffset(40, 40),
		})
		pill.Parent = props.target
	end,
}
