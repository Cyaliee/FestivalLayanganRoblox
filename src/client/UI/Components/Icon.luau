--!strict
-- Ikon dari Config/UIAssets. Kalau Image kosong, tampil Fallback (emoji/teks).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)

local Children = Fusion.Children

export type Props = {
	Name: string?,
	Asset: any, -- UIAssets.IconAsset atau state-nya (boleh nil = kosong)
	Size: any?,
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
	ZIndex: number?,
	Transparency: any?, -- untuk slot kosong/disabled
}

return function(scope: any, props: Props): Instance
	local image = scope:Computed(function(use)
		local asset = use(props.Asset)
		return if asset then asset.Image else ""
	end)
	local fallback = scope:Computed(function(use)
		local asset = use(props.Asset)
		return if asset then asset.Fallback else ""
	end)

	return scope:New("Frame")({
		Name = props.Name or "Icon",
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundTransparency = 1,

		[Children] = {
			scope:New("UIAspectRatioConstraint")({ AspectRatio = 1 }),
			scope:New("ImageLabel")({
				Name = "Image",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ScaleType = Enum.ScaleType.Fit,
				Image = image,
				ImageTransparency = props.Transparency,
				ZIndex = props.ZIndex,
				Visible = scope:Computed(function(use)
					return use(image) ~= ""
				end),
			}),
			scope:New("TextLabel")({
				Name = "Fallback",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				FontFace = Theme.Font,
				Text = fallback,
				TextScaled = true,
				TextColor3 = Theme.Colors.Text,
				TextTransparency = props.Transparency,
				ZIndex = props.ZIndex,
				Visible = scope:Computed(function(use)
					return use(image) == ""
				end),
			}),
		},
	})
end
