--!strict
-- Baris daftar di dalam jendela (item toko, resep). Latar terang, outline warna palette.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Block = require(script.Parent.Block)

export type Props = {
	Name: string?,
	LayoutOrder: number?,
	Height: number,
	Palette: any?,
	Content: { any },
}

local ROW_SURFACE = Color3.fromRGB(236, 240, 246)

return function(scope: any, props: Props): Instance
	return Block(scope, {
		Name = props.Name or "Row",
		Size = UDim2.new(1, -8, 0, props.Height),
		LayoutOrder = props.LayoutOrder,
		Palette = props.Palette,
		SurfaceColor = ROW_SURFACE,
		CornerRadius = Theme.Sizes.PanelCorner,
		Studs = false,
		Padding = 8,
		Content = props.Content,
	})
end
