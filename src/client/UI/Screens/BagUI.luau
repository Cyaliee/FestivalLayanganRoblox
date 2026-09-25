--!strict
-- Jendela Upgrade Tas (dibuka dari tombol di header Inventory).
-- Tombol hanya kirim intent; server yang cek uang & level.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Style = require(script.Parent.Parent.Style)
local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Text = require(Components.Text)
local Icon = require(Components.Icon)
local Button = require(Components.Button)

export type Props = {
	Open: any,
	OnClose: () -> (),
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
	local function line(order: number, text: any, weight: any?, size: number?, color: Color3?)
		return Text(scope, {
			LayoutOrder = order,
			Text = text,
			Weight = weight or "Regular",
			TextSize = size or Theme.Sizes.TextBody,
			Color = color,
			XAlignment = Enum.TextXAlignment.Center,
		})
	end

	return Window(scope, {
		Name = "BagUI",
		Title = UIText.BagTitle,
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(300, 330),
		Content = {
			Style.list(scope, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center),
			Icon(scope, { Asset = UIAssets.Icons.Bag, Size = UDim2.fromOffset(64, 64), LayoutOrder = 0 }),
			line(1, props.BagLevelText, "Black", 18),
			line(2, props.BagUsageText, "Regular", 14, Theme.Colors.TextDim),
			line(3, props.BagNextText, "Regular", 14, Theme.Colors.TextDim),
			line(
				4,
				scope:Computed(function(use)
					return if use(props.BagIsMax) then "" else use(props.BagCostText)
				end),
				"Bold",
				14,
				Theme.Colors.Money
			),
			Button(scope, {
				Name = "UpgradeButton",
				LayoutOrder = 5,
				Size = UDim2.fromOffset(180, 40),
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
