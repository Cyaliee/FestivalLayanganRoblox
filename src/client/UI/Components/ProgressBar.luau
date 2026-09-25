--!strict
-- Bar progress (EXP, dll). Fill bergerak halus dengan Spring.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Style = require(script.Parent.Parent.Style)
local Label = require(script.Parent.Label)

local Children = Fusion.Children

export type Props = {
	Name: string?,
	Size: any?,
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
	Progress: any, -- 0..1 (boleh state)
	Text: any?,
	Palette: any?, -- default Theme.Palettes.Exp
}

return function(scope: any, props: Props): Instance
	local progress = scope:Spring(
		scope:Computed(function(use)
			return math.clamp(use(props.Progress) or 0, 0, 1)
		end),
		Theme.Animation.BarSpeed,
		Theme.Animation.BarDamping
	)

	return scope:New("Frame")({
		Name = props.Name or "ProgressBar",
		Size = props.Size or UDim2.fromOffset(200, 28),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		BackgroundColor3 = Theme.Colors.Track,

		[Children] = Style.children(
			Style.corner(scope, UDim.new(1, 0)),
			Style.outline(scope),
			scope:New("Frame")({
				Name = "Fill",
				Size = scope:Computed(function(use)
					return UDim2.fromScale(math.max(use(progress), 0), 1)
				end),
				Visible = scope:Computed(function(use)
					return use(progress) > 0.01
				end),
				BackgroundColor3 = Color3.new(1, 1, 1),
				[Children] = {
					Style.corner(scope, UDim.new(1, 0)),
					Style.gradient(scope, props.Palette or Theme.Palettes.Exp),
				},
			}),
			props.Text and Label(scope, {
				Name = "Text",
				Text = props.Text,
				Size = UDim2.fromScale(1, 0.8),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = 2,
			})
		),
	})
end
