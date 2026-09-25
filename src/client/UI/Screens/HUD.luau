--!strict
-- HUD: kapsul Bambu / Layangan / Tas (kiri atas), kartu profil (kanan bawah), notifikasi (atas).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Components = script.Parent.Parent.Components
local StatPill = require(Components.StatPill)
local Toast = require(Components.Toast)
local ProfileCard = require(Components.ProfileCard)

local Children = Fusion.Children
local Sizes = Theme.Sizes

export type Props = {
	-- Kartu profil
	DisplayName: any,
	UserId: any,
	MoneyText: any,
	LevelCardText: any,
	ExpShortText: any,
	ExpProgress: any,
	-- Kapsul
	BambooText: any,
	KiteText: any,
	BagText: any,
	BagFull: any,
	OnBagClick: (() -> ())?,
	-- Notifikasi (UIState)
	NotificationText: any,
	NotificationVisible: any,
	Scale: any?,
}

return function(scope: any, props: Props): Instance
	return scope:New("Frame")({
		Name = "HUD",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		[Children] = {
			scope:New("Frame")({
				Name = "StatusPanel",
				Position = UDim2.fromOffset(Sizes.ScreenMargin + 12, Sizes.ScreenMargin),
				Size = UDim2.fromOffset(Sizes.PillWidth + 20, 200),
				BackgroundTransparency = 1,

				[Children] = {
					scope:New("UIScale")({ Scale = props.Scale or 1 }),
					scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 10 + Sizes.ShadowOffset),
					}),
					StatPill(scope, {
						Name = "BambooText",
						Icon = UIAssets.Icons.Bamboo,
						Text = props.BambooText,
						Palette = "Bamboo",
						LayoutOrder = 1,
					}),
					StatPill(scope, {
						Name = "KiteText",
						Icon = UIAssets.Icons.Kite,
						Text = props.KiteText,
						Palette = "Kite",
						LayoutOrder = 2,
					}),
					StatPill(scope, {
						Name = "BagText",
						Icon = UIAssets.Icons.Bag,
						Text = props.BagText,
						Palette = scope:Computed(function(use)
							return if use(props.BagFull) then "BagFull" else "Bag"
						end),
						OnActivated = props.OnBagClick,
						LayoutOrder = 3,
					}),
				},
			}),

			ProfileCard(scope, {
				DisplayName = props.DisplayName,
				UserId = props.UserId,
				MoneyText = props.MoneyText,
				LevelText = props.LevelCardText,
				ExpText = props.ExpShortText,
				ExpProgress = props.ExpProgress,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -Sizes.ScreenMargin, 1, -Sizes.ScreenMargin),
				Scale = props.Scale,
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
