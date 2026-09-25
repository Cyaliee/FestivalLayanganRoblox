--!strict
-- Ikon gambar dari Config/UIAssets. Selama Image kosong, tampil Label placeholder (bukan emoji).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)

local Children = Fusion.Children

export type Props = {
	Name: string?,
	Asset: any, -- UIAssets.IconAsset (boleh state / nil)
	Size: any?,
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
	ZIndex: number?,
	Color: any?, -- ImageColor3
	Transparency: any?,
}

return function(scope: any, props: Props): Instance
	local image = scope:Computed(function(use)
		local asset = use(props.Asset)
		return if asset then asset.Image else ""
	end)
	local label = scope:Computed(function(use)
		local asset = use(props.Asset)
		return if asset then asset.Label else ""
	end)

	return scope:New("ImageLabel")({
		Name = props.Name or "Icon",
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Image = image,
		ImageColor3 = props.Color,
		ImageTransparency = props.Transparency,
		[Children] = {
			scope:New("TextLabel")({
				Name = "Placeholder",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = label,
				FontFace = Theme.Fonts.Bold,
				TextColor3 = Theme.Colors.TextMuted,
				TextScaled = true,
				ZIndex = props.ZIndex,
				Visible = scope:Computed(function(use)
					return use(image) == ""
				end),
				[Children] = {
					scope:New("UITextSizeConstraint")({ MaxTextSize = 14, MinTextSize = 6 }),
				},
			}),
		},
	})
end
