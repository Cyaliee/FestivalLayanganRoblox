--!strict
-- ScrollingFrame vertikal (list atau grid), scrollbar tipis putih seperti referensi Inventory.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)

local Children = Fusion.Children

export type Props = {
	Name: string?,
	Size: any?,
	Position: any?,
	Layout: ("List" | "Grid")?,
	CellSize: number?, -- grid: ukuran sel (px)
	Gap: number?,
	Content: any, -- array instance atau state (ForValues)
}

return function(scope: any, props: Props): Instance
	local gap = props.Gap or 8
	local layout = if props.Layout == "Grid"
		then scope:New("UIGridLayout")({
			CellSize = UDim2.fromOffset(props.CellSize or 56, props.CellSize or 56),
			CellPadding = UDim2.fromOffset(gap, gap),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		})
		else scope:New("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, gap),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		})

	return scope:New("ScrollingFrame")({
		Name = props.Name or "List",
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Colors.Stroke,
		ScrollBarImageTransparency = 0.3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		[Children] = {
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 10),
			}),
			layout,
			props.Content,
		},
	})
end
