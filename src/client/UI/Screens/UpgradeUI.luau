--!strict
-- Jendela Upgrade Meja Rakit (dibuka dari Papan Nama kavling).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local Style = require(script.Parent.Parent.Style)
local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Text = require(Components.Text)
local Button = require(Components.Button)

export type Props = {
	Open: any,
	OnClose: () -> (),
	CurrentLevel: any, -- number (state)
	MaxLevel: number,
	CostText: any,
	InfoText: any?,
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
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(320, 320),
		Content = {
			Style.list(scope, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center),
			Text(scope, {
				Name = "CurrentLevel",
				LayoutOrder = 1,
				Weight = "Black",
				TextSize = 18,
				XAlignment = Enum.TextXAlignment.Center,
				Text = scope:Computed(function(use)
					return string.format(UIText.CurrentLevel, use(props.CurrentLevel))
				end),
			}),
			Text(scope, {
				Name = "NextLevel",
				LayoutOrder = 2,
				Weight = "Regular",
				Color = Theme.Colors.TextDim,
				XAlignment = Enum.TextXAlignment.Center,
				Text = scope:Computed(function(use)
					if use(isMax) then
						return UIText.MaxLevel
					end
					return string.format(UIText.NextLevel, use(props.CurrentLevel) + 1)
				end),
			}),
			Text(scope, {
				Name = "InfoText",
				LayoutOrder = 3,
				Weight = "Regular",
				TextSize = 12,
				Color = Theme.Colors.TextDim,
				XAlignment = Enum.TextXAlignment.Center,
				Wrapped = true,
				Size = UDim2.new(1, 0, 0, 40),
				Text = props.InfoText or "",
			}),
			Text(scope, {
				Name = "CostText",
				LayoutOrder = 4,
				Color = Theme.Colors.Money,
				XAlignment = Enum.TextXAlignment.Center,
				Text = scope:Computed(function(use)
					return string.format(UIText.Cost, use(props.CostText))
				end),
			}),
			Button(scope, {
				Name = "UpgradeButton",
				LayoutOrder = 5,
				Size = UDim2.fromOffset(180, 40),
				Text = props.UpgradeText,
				Disabled = scope:Computed(function(use)
					return use(isMax) or use(props.UpgradeDisabled) == true
				end),
				OnActivated = props.OnUpgrade,
			}),
		},
	})
end
