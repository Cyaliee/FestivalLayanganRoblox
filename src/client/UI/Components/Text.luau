--!strict
-- Teks Gotham (Black/Bold/Regular). TextSize tetap; skala layar diurus UIScale.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Style = require(script.Parent.Parent.Style)

local Children = Fusion.Children

export type Props = {
	Name: string?,
	Text: any,
	Weight: ("Black" | "Bold" | "Regular")?,
	TextSize: number?,
	Color: any?,
	Transparency: any?,
	Size: any?,
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: any?,
	XAlignment: Enum.TextXAlignment?,
	YAlignment: Enum.TextYAlignment?,
	Wrapped: boolean?,
	AutomaticSize: Enum.AutomaticSize?,
	Metallic: boolean?, -- gradient metalik seperti judul DonationMenu
	Truncate: boolean?,
	Outline: boolean?, -- garis tepi teks gelap (untuk teks di atas dunia 3D)
}

return function(scope: any, props: Props): Instance
	local textSize = props.TextSize or Theme.Sizes.TextBody
	return scope:New("TextLabel")({
		Name = props.Name or "Text",
		Text = props.Text,
		FontFace = Theme.Fonts[props.Weight or "Bold"],
		TextSize = textSize,
		TextColor3 = props.Color or Theme.Colors.Text,
		TextTransparency = props.Transparency,
		Size = props.Size or UDim2.new(1, 0, 0, textSize + 4),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		BackgroundTransparency = 1,
		TextXAlignment = props.XAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.YAlignment or Enum.TextYAlignment.Center,
		TextWrapped = props.Wrapped == true,
		TextTruncate = if props.Truncate then Enum.TextTruncate.AtEnd else Enum.TextTruncate.None,
		AutomaticSize = props.AutomaticSize,
		TextStrokeTransparency = if props.Outline then 0.4 else 1,
		TextStrokeColor3 = Theme.Colors.Backdrop,
		[Children] = Style.children(props.Metallic and Style.metallic(scope)),
	})
end
