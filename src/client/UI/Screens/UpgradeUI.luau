--!strict
-- Jendela Upgrade Meja Rakit. Biaya & aksi upgrade disambungkan di Fase 4.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Label = require(Components.Label)
local StudButton = require(Components.StudButton)
local Style = require(script.Parent.Parent.Style)

export type Props = {
	Open: any,
	OnClose: () -> (),
	CurrentLevel: any, -- number (state)
	MaxLevel: number,
	CostText: any, -- string (state)
	InfoText: any?, -- kecepatan & resep yang terbuka (state)
	UpgradeText: any,
	UpgradeDisabled: any,
	OnUpgrade: () -> (),
	Scale: any?,
}

return function(scope: any, props: Props): Instance
	local isMax = scope:Computed(function(use)
		return use(props.CurrentLevel) >= props.MaxLevel
	end)

	return Window(scope, {
		Name = "UpgradeUI",
		Title = UIText.UpgradeTitle,
		Palette = "UpgradeWindow",
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(460, 400),
		Content = {
			Style.padding(scope, 20),
			scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 10),
			}),
			Label(scope, {
				Name = "CurrentLevel",
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 36),
				Text = scope:Computed(function(use)
					return string.format(UIText.CurrentLevel, use(props.CurrentLevel))
				end),
			}),
			Label(scope, {
				Name = "NextLevel",
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 30),
				Text = scope:Computed(function(use)
					if use(isMax) then
						return UIText.MaxLevel
					end
					return string.format(UIText.NextLevel, use(props.CurrentLevel) + 1)
				end),
			}),
			Label(scope, {
				Name = "CostText",
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, 30),
				Text = scope:Computed(function(use)
					return string.format(UIText.Cost, use(props.CostText))
				end),
			}),
			Label(scope, {
				Name = "InfoText",
				LayoutOrder = 4,
				Size = UDim2.new(1, 0, 0, 44),
				Text = props.InfoText or "",
				MaxTextSize = 20,
			}),
			StudButton(scope, {
				Name = "UpgradeButton",
				LayoutOrder = 5,
				Size = UDim2.fromOffset(220, 62),
				Variant = "Primary",
				Icon = UIAssets.Icons.Upgrade,
				Text = props.UpgradeText,
				Disabled = scope:Computed(function(use)
					return use(isMax) or use(props.UpgradeDisabled) == true
				end),
				OnActivated = props.OnUpgrade,
			}),
		},
	})
end
