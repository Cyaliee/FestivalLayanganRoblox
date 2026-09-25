--!strict
-- Bar progress tipis (EXP, sisa terbang, HP pohon). Fill bergerak halus dengan Spring.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Style = require(script.Parent.Parent.Style)

local Children = Fusion.Children

export type Props = {
	Name: string?,
	Progress: any, -- 0..1 (state)
	Text: any?, -- teks di tengah bar (opsional)
	FillColor: any?,
	Size: any?,
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
	Visible: any?,
	ZIndex: number?,
}

return function(scope: any, props: Props): Instance
	local progress = scope:Spring(
		scope:Computed(function(use)
			return math.clamp(use(props.Progress) or 0, 0, 1)
		end),
		Theme.Animation.BarSpeed,
		Theme.Animation.BarDamping
	)
	local round = UDim.new(1, 0)

	return scope:New("Frame")({
		Name = props.Name or "ProgressBar",
		Size = props.Size or UDim2.new(1, 0, 0, 10),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		BackgroundColor3 = Theme.Colors.Track,
		[Children] = Style.children(
			Style.corner(scope, round),
			Style.stroke(scope, { Transparency = 0.85 }),
			scope:New("Frame")({
				Name = "Fill",
				Size = scope:Computed(function(use)
					return UDim2.fromScale(math.max(use(progress), 0), 1)
				end),
				Visible = scope:Computed(function(use)
					return use(progress) > 0.005
				end),
				BackgroundColor3 = props.FillColor or Theme.Colors.ExpFill,
				ZIndex = props.ZIndex,
				[Children] = {
					Style.corner(scope, round),
					Style.metallic(scope),
				},
			}),
			props.Text and scope:New("TextLabel")({
				Name = "Label",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = props.Text,
				FontFace = Theme.Fonts.Bold,
				TextSize = Theme.Sizes.TextSmall,
				TextColor3 = Theme.Colors.Text,
				ZIndex = (props.ZIndex or 1) + 1,
			})
		),
	})
end
