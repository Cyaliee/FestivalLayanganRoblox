--!strict
-- Kapsul status (ikon + angka). Membal saat angkanya berubah.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Panel = require(script.Parent.Panel)
local Label = require(script.Parent.Label)
local Icon = require(script.Parent.Icon)

local Anim = Theme.Animation
local Sizes = Theme.Sizes

export type Props = {
	Name: string?,
	Icon: any,
	Text: any,
	Warning: any?, -- true = merah (mis. tas penuh)
	LayoutOrder: number?,
	Position: any?,
}

return function(scope: any, props: Props): Instance
	local bump = scope:Spring(1, Anim.BumpSpeed, Anim.BumpDamping)
	if type(props.Text) == "table" then
		scope:Observer(props.Text):onChange(function()
			bump:setPosition(Anim.BumpScale)
		end)
	end

	return Panel(scope, {
		Name = props.Name or "StatPill",
		Size = UDim2.fromOffset(Sizes.PillWidth, Sizes.PillHeight),
		Position = props.Position,
		LayoutOrder = props.LayoutOrder,
		CornerRadius = UDim.new(1, 0),
		Palette = scope:Computed(function(use)
			return if use(props.Warning) == true then Theme.Palettes.Danger else Theme.Palettes.PanelDark
		end),
		Content = {
			scope:New("UIScale")({ Scale = bump }),
			Icon(scope, {
				Asset = props.Icon,
				Size = UDim2.fromOffset(Sizes.PillHeight + 10, Sizes.PillHeight + 10),
				Position = UDim2.new(0, -12, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				ZIndex = 2,
			}),
			Label(scope, {
				Text = props.Text,
				Size = UDim2.new(1, -(Sizes.PillHeight + 8), 0.75, 0),
				Position = UDim2.new(0, Sizes.PillHeight + 2, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		},
	})
end
