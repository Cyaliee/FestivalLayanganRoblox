--!strict
-- HUD: level + EXP, koin, bambu, layangan, tas, dan notifikasi.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Components = script.Parent.Parent.Components
local Panel = require(Components.Panel)
local Label = require(Components.Label)
local ProgressBar = require(Components.ProgressBar)
local StatPill = require(Components.StatPill)
local Toast = require(Components.Toast)

local Children = Fusion.Children
local Sizes = Theme.Sizes

export type Props = {
	-- dari PlayerView.derive
	LevelText: any,
	ExpProgress: any,
	ExpText: any,
	CoinsText: any,
	BambooText: any,
	KiteText: any,
	BagText: any,
	BagFull: any,
	-- dari UIState
	NotificationText: any,
	NotificationVisible: any,
	Scale: any?,
}

local BADGE_SIZE = 64

return function(scope: any, props: Props): Instance
	return scope:New("Frame")({
		Name = "HUD",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		[Children] = {
			scope:New("Frame")({
				Name = "StatusPanel",
				Position = UDim2.fromOffset(Sizes.ScreenMargin, Sizes.ScreenMargin),
				Size = UDim2.fromOffset(Sizes.PillWidth + 60, 360),
				BackgroundTransparency = 1,

				[Children] = {
					scope:New("UIScale")({ Scale = props.Scale or 1 }),
					scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 10 + Sizes.ShadowOffset),
					}),

					-- Level badge + EXP bar
					scope:New("Frame")({
						Name = "LevelRow",
						LayoutOrder = 1,
						Size = UDim2.fromOffset(Sizes.PillWidth + 60, BADGE_SIZE),
						BackgroundTransparency = 1,
						[Children] = {
							ProgressBar(scope, {
								Name = "ExpBar",
								Progress = props.ExpProgress,
								Text = props.ExpText,
								Size = UDim2.fromOffset(Sizes.PillWidth + 10, 30),
								Position = UDim2.new(0, BADGE_SIZE - 14, 0.5, 0),
								AnchorPoint = Vector2.new(0, 0.5),
							}),
							Panel(scope, {
								Name = "LevelBadge",
								Size = UDim2.fromOffset(BADGE_SIZE, BADGE_SIZE),
								CornerRadius = UDim.new(1, 0),
								Palette = "Level",
								Padding = 8,
								ZIndex = 2,
								Content = {
									Label(scope, {
										Name = "LevelText",
										Text = props.LevelText,
										Font = Theme.TitleFont,
										ZIndex = 3,
									}),
								},
							}),
						},
					}),

					StatPill(scope, {
						Name = "CoinText",
						Icon = UIAssets.Icons.Coin,
						Text = props.CoinsText,
						Palette = "Coin",
						LayoutOrder = 2,
					}),
					StatPill(scope, {
						Name = "BambooText",
						Icon = UIAssets.Icons.Bamboo,
						Text = props.BambooText,
						Palette = "Bamboo",
						LayoutOrder = 3,
					}),
					StatPill(scope, {
						Name = "KiteText",
						Icon = UIAssets.Icons.Kite,
						Text = props.KiteText,
						Palette = "Kite",
						LayoutOrder = 4,
					}),
					StatPill(scope, {
						Name = "BagText",
						Icon = UIAssets.Icons.Bag,
						Text = props.BagText,
						Palette = scope:Computed(function(use)
							return if use(props.BagFull) then "BagFull" else "Bag"
						end),
						LayoutOrder = 5,
					}),
				},
			}),

			scope:New("Frame")({
				Name = "NotificationArea",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				[Children] = {
					Toast(scope, {
						Text = props.NotificationText,
						Visible = props.NotificationVisible,
						Scale = props.Scale,
					}),
				},
			}),
		},
	})
end
