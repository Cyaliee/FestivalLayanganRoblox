--!strict
-- Potongan gaya yang dipakai semua komponen (sudut, outline, stud, padding, palette).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)

local Children = Fusion.Children

local Style = {}

export type Palette = { Surface: Color3, Dark: Color3 }

-- Terima nama palette ("Green"), nama role ("Primary"), atau tabel palette.
function Style.palette(value: any): Palette
	if type(value) == "table" then
		return value
	end
	if type(value) == "string" then
		local direct = Theme.Palettes[value]
		if direct then
			return direct
		end
		local role = Theme.Roles[value]
		if role and Theme.Palettes[role] then
			return Theme.Palettes[role]
		end
	end
	return Theme.Palettes[Theme.Roles.Primary]
end

function Style.corner(scope: any, radius: any?): Instance
	return scope:New("UICorner")({
		CornerRadius = radius or Theme.Sizes.Corner,
	})
end

-- Outline tebal di pinggir, warnanya boleh state
function Style.outline(scope: any, color: any, enabled: any?): Instance
	return scope:New("UIStroke")({
		Color = color,
		Thickness = Theme.Sizes.Outline,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Round,
		Enabled = enabled,
	})
end

-- Tekstur stud yang terpotong mengikuti sudut bulat (CanvasGroup seperti di kit)
function Style.studs(scope: any, transparency: number, radius: any?, visible: any?): Instance
	return scope:New("CanvasGroup")({
		Name = "StudsMask",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = visible,
		ZIndex = 1,
		[Children] = {
			Style.corner(scope, radius),
			scope:New("ImageLabel")({
				Name = "Studs",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = Theme.Studs.Image,
				ImageTransparency = transparency,
				ScaleType = Enum.ScaleType.Tile,
				TileSize = UDim2.fromOffset(Theme.Studs.TileSize, Theme.Studs.TileSize),
			}),
		},
	})
end

function Style.padding(scope: any, px: number): Instance
	local udim = UDim.new(0, px)
	return scope:New("UIPadding")({
		PaddingTop = udim,
		PaddingBottom = udim,
		PaddingLeft = udim,
		PaddingRight = udim,
	})
end

-- Isi Children tanpa nil (Fusion tidak suka lubang di array)
function Style.children(...: any): { any }
	local list = {}
	for i = 1, select("#", ...) do
		local child = select(i, ...)
		if child ~= nil and child ~= false then
			table.insert(list, child)
		end
	end
	return list
end

return Style
