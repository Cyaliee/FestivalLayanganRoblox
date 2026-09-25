--!strict
-- Panel gelap (25,25,25) dengan sudut 12 & stroke putih tipis.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Style = require(script.Parent.Parent.Style)

local Children = Fusion.Children

export type Props = {
	Name: string?,
	Size: any?,
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: any?,
	AutomaticSize: Enum.AutomaticSize?,
	Color: any?,
	Transparency: any?,
	StrokeColor: any?,
	StrokeTransparency: any?,
	StrokeThickness: number?,
	Corner: UDim?,
	Padding: number?,
	ClipsDescendants: boolean?,
	Content: { any }?,
}

return function(scope: any, props: Props): Instance
	return scope:New("Frame")({
		Name = props.Name or "Panel",
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		AutomaticSize = props.AutomaticSize,
		ClipsDescendants = props.ClipsDescendants,
		BackgroundColor3 = props.Color or Theme.Colors.Panel,
		BackgroundTransparency = props.Transparency or 0,
		[Children] = Style.children(
			Style.corner(scope, props.Corner or Theme.Sizes.PanelCorner),
			Style.stroke(scope, {
				Color = props.StrokeColor,
				Transparency = props.StrokeTransparency or Theme.Transparency.PanelStroke,
				Thickness = props.StrokeThickness,
			}),
			props.Padding and Style.padding(scope, props.Padding),
			props.Content
		),
	})
end
