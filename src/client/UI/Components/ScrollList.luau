--!strict
-- ScrollingFrame vertikal dengan UIListLayout (tinggi kanvas otomatis).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)

local Children = Fusion.Children

export type Props = {
	Size: any?,
	Position: any?,
	Gap: number?,
	Content: { any },
}

return function(scope: any, props: Props): Instance
	return scope:New("ScrollingFrame")({
		Name = "List",
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 8,
		ScrollBarImageColor3 = Theme.Palettes.Dark.Surface,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ZIndex = 3,
		[Children] = {
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
			}),
			scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, props.Gap or (8 + Theme.Sizes.ShadowOffset)),
			}),
			props.Content,
		},
	})
end
