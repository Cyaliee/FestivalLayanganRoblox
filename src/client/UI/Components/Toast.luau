--!strict
-- Notifikasi yang meluncur dari atas layar ("Tas Penuh!", "Kavling berhasil diklaim!", ...).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Block = require(script.Parent.Block)
local Label = require(script.Parent.Label)

local Anim = Theme.Animation

export type Props = {
	Text: any,
	Visible: any, -- boolean (state)
	Palette: any?,
	Scale: any?,
}

return function(scope: any, props: Props): Instance
	local y = scope:Spring(
		scope:Computed(function(use)
			return if use(props.Visible) then Anim.ToastShownY else Anim.ToastHiddenY
		end),
		Anim.ToastSpeed,
		Anim.ToastDamping
	)

	return Block(scope, {
		Name = "Notification",
		Size = UDim2.fromOffset(Theme.Sizes.ToastWidth, Theme.Sizes.ToastHeight),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = scope:Computed(function(use)
			return UDim2.new(0.5, 0, 0, use(y))
		end),
		CornerRadius = Theme.Sizes.PanelCorner,
		Palette = props.Palette or "Toast",
		Scale = props.Scale,
		Padding = 8,
		Content = {
			Label(scope, {
				Name = "MessageText",
				Text = props.Text,
				ZIndex = 3,
			}),
		},
	})
end
