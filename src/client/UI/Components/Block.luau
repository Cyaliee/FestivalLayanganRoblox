--!strict
--[[
	Blok dasar gaya Studded: permukaan warna solid + tekstur stud + outline gelap
	+ bayangan bawah (warna gelap yang sama). Dipakai Panel, StudButton, dll.

	Struktur:
	  <Root Frame transparan> (UIScale)
	    Shadow  : warna Dark, digeser ke bawah
	    Face    : Frame / ImageButton warna Surface
	      StudsMask (CanvasGroup), Content (ZIndex 2)
]]
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
	Palette: any?, -- nama palette/role atau tabel { Surface, Dark } (boleh state)
	SurfaceColor: any?, -- override warna permukaan (mis. putih untuk badan jendela)
	CornerRadius: any?,
	Studs: number | false | nil, -- transparansi stud; false = tanpa stud
	Shadow: boolean?, -- default true
	Scale: any?, -- UIScale root (boleh state)
	Sink: any?, -- px permukaan turun (boleh state), untuk efek ditekan
	FaceClass: string?, -- "Frame" (default) atau "ImageButton"
	FaceProps: { [any]: any }?, -- properti/event tambahan untuk Face
	HideDecor: any?, -- true = sembunyikan warna/outline/stud (dipakai saat skin gambar)
	Padding: number?,
	Content: { any }?,
}

return function(scope: any, props: Props): Instance
	local palette = scope:Computed(function(use)
		return Style.palette(use(props.Palette))
	end)
	local dark = scope:Computed(function(use)
		return use(palette).Dark
	end)
	local decor = scope:Computed(function(use)
		return use(props.HideDecor) ~= true
	end)
	local radius = props.CornerRadius or Theme.Sizes.Corner
	local shadowOffset = Theme.Sizes.ShadowOffset

	local faceProps: { [any]: any } = {
		Name = "Face",
		Size = UDim2.fromScale(1, 1),
		Position = scope:Computed(function(use)
			return UDim2.fromOffset(0, use(props.Sink) or 0)
		end),
		BackgroundColor3 = scope:Computed(function(use)
			return use(props.SurfaceColor) or use(palette).Surface
		end),
		BackgroundTransparency = scope:Computed(function(use)
			return if use(decor) then 0 else 1
		end),
		ZIndex = 2,

		[Children] = Style.children(
			Style.corner(scope, radius),
			Style.outline(scope, dark, decor),
			props.Studs ~= false and Style.studs(
				scope,
				props.Studs or Theme.Studs.ButtonTransparency,
				radius,
				decor
			),
			scope:New("Frame")({
				Name = "Content",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = 2,
				[Children] = Style.children(props.Padding and Style.padding(scope, props.Padding), props.Content),
			})
		),
	}
	if props.FaceProps then
		for key, value in props.FaceProps do
			faceProps[key] = value
		end
	end

	return scope:New("Frame")({
		Name = props.Name or "Block",
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		BackgroundTransparency = 1,

		[Children] = Style.children(
			scope:New("UIScale")({ Scale = props.Scale or 1 }),
			props.Shadow ~= false and scope:New("Frame")({
				Name = "Shadow",
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(0, shadowOffset),
				BackgroundColor3 = dark,
				Visible = decor,
				ZIndex = 1,
				[Children] = {
					Style.corner(scope, radius),
					Style.outline(scope, dark),
				},
			}),
			scope:New(props.FaceClass or "Frame")(faceProps)
		),
	})
end
