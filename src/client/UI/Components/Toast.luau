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
	Name: string?,
	Size: UDim2?,
	ShownY: number?, -- posisi Y saat tampil (default UITheme.Animation.ToastShownY)
	MaxTextSize: number?,
}

return function(scope: any, props: Props): Instance
	local y = scope:Spring(
		scope:Computed(function(use)
			return if use(props.Visible) then props.ShownY or Anim.ToastShownY else Anim.ToastHiddenY
		end),
		Anim.ToastSpeed,
		Anim.ToastDamping
	)

	return Block(scope, {
		Name = props.Name or "Notification",
		Size = props.Size or UDim2.fromOffset(Theme.Sizes.ToastWidth, Theme.Sizes.ToastHeight),
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
				MaxTextSize = props.MaxTextSize,
				ZIndex = 3,
			}),
		},
	})
end
