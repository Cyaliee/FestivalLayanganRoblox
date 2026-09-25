--!strict
-- Bar progress (EXP, dll) gaya Studded. Fill bergerak halus dengan Spring.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Style = require(script.Parent.Parent.Style)
local Block = require(script.Parent.Block)
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
	Palette: any?, -- warna isi, default role "Exp"
	TrackPalette: any?, -- warna track, default role "ExpTrack"
}

local ROUND = UDim.new(1, 0)

return function(scope: any, props: Props): Instance
	local progress = scope:Spring(
		scope:Computed(function(use)
			return math.clamp(use(props.Progress) or 0, 0, 1)
		end),
		Theme.Animation.BarSpeed,
		Theme.Animation.BarDamping
	)
	local fill = Style.palette(props.Palette or "Exp")

	return Block(scope, {
		Name = props.Name or "ProgressBar",
		Size = props.Size or UDim2.fromOffset(200, 28),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		Palette = props.TrackPalette or "ExpTrack",
		CornerRadius = ROUND,
		Studs = false,
		Content = Style.children(
			scope:New("Frame")({
				Name = "Fill",
				Size = scope:Computed(function(use)
					return UDim2.fromScale(math.max(use(progress), 0), 1)
				end),
				Visible = scope:Computed(function(use)
					return use(progress) > 0.01
				end),
				BackgroundColor3 = fill.Surface,
				[Children] = {
					Style.corner(scope, ROUND),
					Style.studs(scope, Theme.Studs.ButtonTransparency, ROUND),
				},
			}),
			props.Text and Label(scope, {
				Name = "Text",
				Text = props.Text,
				Size = UDim2.fromScale(1, 0.8),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = 3,
			})
		),
	})
end
