--!strict
-- Notifikasi gelap yang meluncur dari atas. Dipakai juga untuk banner pengumuman global.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Style = require(script.Parent.Parent.Style)

local Children = Fusion.Children
local Anim = Theme.Animation

export type Props = {
	Name: string?,
	Text: any,
	Visible: any, -- boolean (state)
	AccentColor: any?, -- warna stroke (mis. warna rarity untuk pengumuman)
	Size: UDim2?,
	ShownY: number?,
	TextSize: number?,
	Scale: any?,
}

return function(scope: any, props: Props): Instance
	local y = scope:Spring(
		scope:Computed(function(use)
			return if use(props.Visible) then props.ShownY or Anim.ToastShownY else Anim.ToastHiddenY
		end),
		Anim.ToastSpeed,
		Anim.ToastDamping
	)

	return scope:New("Frame")({
		Name = props.Name or "Notification",
		Size = props.Size or UDim2.fromOffset(Theme.Sizes.ToastWidth, Theme.Sizes.ToastHeight),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = scope:Computed(function(use)
			return UDim2.new(0.5, 0, 0, use(y))
		end),
		BackgroundColor3 = Theme.Colors.Bar,
		BackgroundTransparency = Theme.Transparency.Bar,
		[Children] = {
			scope:New("UIScale")({ Scale = props.Scale or 1 }),
			Style.corner(scope, Theme.Sizes.BarCorner),
			Style.stroke(scope, {
				Color = props.AccentColor,
				Thickness = if props.AccentColor then 2 else 1,
				Transparency = if props.AccentColor then 0 else Theme.Transparency.PanelStroke,
			}),
			Style.padding(scope, 4, 14),
			scope:New("TextLabel")({
				Name = "MessageText",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = props.Text,
				FontFace = Theme.Fonts.Bold,
				TextSize = props.TextSize or Theme.Sizes.TextBody,
				TextColor3 = Theme.Colors.Text,
				TextWrapped = true,
			}),
		},
	})
end
