--!strict
-- Jendela Tas: level, isi, kapasitas level berikutnya, harga, tombol Upgrade.
-- Tombol hanya kirim intent; server yang cek koin & level.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Label = require(Components.Label)
local Icon = require(Components.Icon)
local StudButton = require(Components.StudButton)
local Style = require(script.Parent.Parent.Style)

export type Props = {
	Open: any,
	OnClose: () -> (),
	-- dari PlayerView.derive
	BagLevelText: any,
	BagUsageText: any,
	BagNextText: any,
	BagCostText: any,
	BagIsMax: any,
	BagCanAfford: any,
	OnUpgrade: () -> (),
	Scale: any?,
}

return function(scope: any, props: Props): Instance
	return Window(scope, {
		Name = "BagUI",
		Title = UIText.BagTitle,
		Palette = "Bag",
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(440, 380),
		Content = {
			Style.padding(scope, 16),
			scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 8),
			}),
			Icon(scope, {
				Name = "BagIcon",
				Asset = UIAssets.Icons.Bag,
				Size = UDim2.fromOffset(72, 72),
				LayoutOrder = 1,
			}),
			Label(scope, {
				Name = "LevelText",
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 38),
				Text = props.BagLevelText,
				MaxTextSize = 34,
			}),
			Label(scope, {
				Name = "UsageText",
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, 26),
				Text = props.BagUsageText,
			}),
			Label(scope, {
				Name = "NextText",
				LayoutOrder = 4,
				Size = UDim2.new(1, 0, 0, 26),
				Text = props.BagNextText,
			}),
			Label(scope, {
				Name = "CostText",
				LayoutOrder = 5,
				Size = UDim2.new(1, 0, 0, 26),
				Text = scope:Computed(function(use)
					return if use(props.BagIsMax) then "" else use(props.BagCostText)
				end),
			}),
			StudButton(scope, {
				Name = "UpgradeButton",
				LayoutOrder = 6,
				Size = UDim2.fromOffset(220, 58),
				Variant = "Primary",
				Icon = UIAssets.Icons.Upgrade,
				Text = scope:Computed(function(use)
					if use(props.BagIsMax) then
						return UIText.BagMaxLevel
					end
					return if use(props.BagCanAfford) then UIText.BagUpgradeButton else UIText.BagNotEnoughCoins
				end),
				Disabled = scope:Computed(function(use)
					return use(props.BagIsMax) or not use(props.BagCanAfford)
				end),
				OnActivated = props.OnUpgrade,
			}),
		},
	})
end
