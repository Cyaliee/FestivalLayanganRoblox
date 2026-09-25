--!strict
-- Potongan gaya bersama (tema gelap metalik): sudut, stroke, gradient metalik, padding.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)

local Style = {}

function Style.corner(scope: any, radius: UDim?): Instance
	return scope:New("UICorner")({ CornerRadius = radius or Theme.Sizes.Corner })
end

-- Stroke pinggir; color/transparency boleh state
function Style.stroke(scope: any, props: { Color: any?, Transparency: any?, Thickness: number?, Enabled: any? }?): Instance
	local p = props or {}
	return scope:New("UIStroke")({
		Color = p.Color or Theme.Colors.Stroke,
		Transparency = p.Transparency or Theme.Transparency.ButtonStroke,
		Thickness = p.Thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Enabled = p.Enabled,
	})
end

function Style.metallic(scope: any, enabled: any?): Instance
	return scope:New("UIGradient")({
		Color = Theme.MetallicGradient,
		Rotation = 90,
		Enabled = enabled,
	})
end

function Style.padding(scope: any, top: number, side: number?, bottom: number?): Instance
	local s = side or top
	return scope:New("UIPadding")({
		PaddingTop = UDim.new(0, top),
		PaddingBottom = UDim.new(0, bottom or top),
		PaddingLeft = UDim.new(0, s),
		PaddingRight = UDim.new(0, s),
	})
end

function Style.list(scope: any, direction: Enum.FillDirection?, gap: number?, align: Enum.HorizontalAlignment?): Instance
	return scope:New("UIListLayout")({
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, gap or 8),
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
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
