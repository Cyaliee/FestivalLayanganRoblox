--!strict
-- Kapsul status (ikon + angka) gaya Studded. Membal saat angkanya berubah.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Block = require(script.Parent.Block)
local Label = require(script.Parent.Label)
local Icon = require(script.Parent.Icon)

local Anim = Theme.Animation
local Sizes = Theme.Sizes

export type Props = {
	Name: string?,
	Icon: any,
	Text: any,
	Palette: any?, -- nama palette/role (boleh state)
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

	return Block(scope, {
		Name = props.Name or "StatPill",
		Size = UDim2.fromOffset(Sizes.PillWidth, Sizes.PillHeight),
		Position = props.Position,
		LayoutOrder = props.LayoutOrder,
		CornerRadius = UDim.new(1, 0),
		Palette = props.Palette,
		Scale = bump,
		Content = {
			Icon(scope, {
				Asset = props.Icon,
				Size = UDim2.fromOffset(Sizes.PillHeight + 10, Sizes.PillHeight + 10),
				Position = UDim2.new(0, -12, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				ZIndex = 3,
			}),
			Label(scope, {
				Text = props.Text,
				Size = UDim2.new(1, -(Sizes.PillHeight + 8), 0.75, 0),
				Position = UDim2.new(0, Sizes.PillHeight + 2, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 3,
			}),
		},
	})
end
