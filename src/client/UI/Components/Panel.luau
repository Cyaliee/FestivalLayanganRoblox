--!strict
-- Kotak dasar: sudut bulat + outline tebal + gradient.
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
	Palette: any?, -- { Top, Bottom, Shadow } atau state-nya. Default Theme.Palettes.Panel
	CornerRadius: UDim?,
	Padding: number?,
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
		BackgroundColor3 = Color3.new(1, 1, 1),

		[Children] = Style.children(
			Style.corner(scope, props.CornerRadius),
			Style.outline(scope),
			Style.gradient(scope, props.Palette or Theme.Palettes.Panel),
			props.Padding and Style.padding(scope, props.Padding),
			props.Content
		),
	})
end
