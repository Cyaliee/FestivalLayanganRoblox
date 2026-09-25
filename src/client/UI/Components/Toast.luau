--!strict
-- Notifikasi yang meluncur dari atas layar ("Tas Penuh!", "Kavling berhasil diklaim!", ...).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Panel = require(script.Parent.Panel)
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

	return Panel(scope, {
		Name = "Notification",
		Size = UDim2.fromOffset(Theme.Sizes.ToastWidth, Theme.Sizes.ToastHeight),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = scope:Computed(function(use)
			return UDim2.new(0.5, 0, 0, use(y))
		end),
		Palette = props.Palette or Theme.Palettes.Gold,
		Padding = 8,
		Content = {
			scope:New("UIScale")({ Scale = props.Scale or 1 }),
			Label(scope, {
				Name = "MessageText",
				Text = props.Text,
			}),
		},
	})
end
