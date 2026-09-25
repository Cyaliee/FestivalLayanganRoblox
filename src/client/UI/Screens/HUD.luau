--!strict
-- HUD: kartu profil (kiri bawah), sidebar (kiri tengah), notifikasi (atas).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Components = script.Parent.Parent.Components
local Toast = require(Components.Toast)
local ProfileCard = require(Components.ProfileCard)
local Sidebar = require(script.Parent.Sidebar)

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
	-- Sidebar
	SidebarEntries: { Sidebar.Entry },
	SidebarOpen: any,
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
			ProfileCard(scope, {
				DisplayName = props.DisplayName,
				UserId = props.UserId,
				MoneyText = props.MoneyText,
				LevelText = props.LevelCardText,
				ExpText = props.ExpShortText,
				ExpProgress = props.ExpProgress,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, Sizes.ScreenMargin, 1, -Sizes.ScreenMargin),
				Scale = props.Scale,
			}),

			Sidebar(scope, {
				Entries = props.SidebarEntries,
				Open = props.SidebarOpen,
				Scale = props.Scale,
			}),

			Toast(scope, {
				Text = props.NotificationText,
				Visible = props.NotificationVisible,
				Scale = props.Scale,
			}),
		},
	})
end
