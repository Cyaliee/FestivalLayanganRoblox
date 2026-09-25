--!strict
-- Teks tebal putih dengan outline gelap (gaya cartoon).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)

local Children = Fusion.Children

export type Props = {
	Name: string?,
	Text: any,
	Size: any?,
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
	ZIndex: number?,
	Font: Font?,
	TextColor: any?,
	TextXAlignment: Enum.TextXAlignment?,
	MaxTextSize: number?,
	Visible: any?,
}

return function(scope: any, props: Props): Instance
	return scope:New("TextLabel")({
		Name = props.Name or "Label",
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		BackgroundTransparency = 1,
		FontFace = props.Font or Theme.Font,
		Text = props.Text,
		TextColor3 = props.TextColor or Theme.Colors.Text,
		TextScaled = true,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,

		[Children] = {
			scope:New("UIStroke")({
				Color = Theme.Colors.Outline,
				Thickness = Theme.Sizes.TextStroke,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
				LineJoinMode = Enum.LineJoinMode.Round,
			}),
			scope:New("UITextSizeConstraint")({
				MaxTextSize = props.MaxTextSize or Theme.Sizes.MaxTextSize,
			}),
		},
	})
end
