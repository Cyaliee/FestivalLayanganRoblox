--!strict
-- Potongan gaya yang dipakai semua komponen (outline, sudut, gradient, padding).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)

local Style = {}

-- Gradient atas->bawah dari palette { Top, Bottom, Shadow }. palette boleh state.
function Style.gradient(scope: any, palette: any, enabled: any?): Instance
	return scope:New("UIGradient")({
		Rotation = 90,
		Enabled = enabled,
		Color = scope:Computed(function(use)
			local p = use(palette)
			return ColorSequence.new(p[1], p[2])
		end),
	})
end

function Style.corner(scope: any, radius: UDim?): Instance
	return scope:New("UICorner")({
		CornerRadius = radius or Theme.Sizes.Corner,
	})
end

-- Outline tebal di pinggir frame/tombol
function Style.outline(scope: any, enabled: any?): Instance
	return scope:New("UIStroke")({
		Color = Theme.Colors.Outline,
		Thickness = Theme.Sizes.Outline,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Round,
		Enabled = enabled,
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
