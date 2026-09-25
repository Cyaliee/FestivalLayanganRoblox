--!strict
--[[
	Tombol gaya Studded: warna solid + stud + outline + bayangan bawah.
	Hover = membesar, tekan = mengecil & turun, lepas = membal (Fusion Spring).

	Skin: kalau Config/UIAssets.Buttons[<nama palette>].Image diisi, gambar itu dipakai
	sebagai ImageButton dan gaya bawaan disembunyikan.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Style = require(script.Parent.Parent.Style)
local Block = require(script.Parent.Block)
local Label = require(script.Parent.Label)
local Icon = require(script.Parent.Icon)

local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local Anim = Theme.Animation

export type Props = {
	Name: string?,
	Size: any?,
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
	Variant: any?, -- nama palette/role (boleh state). Default "Primary"
	Text: any?,
	Icon: any?, -- UIAssets.IconAsset (boleh state)
	Disabled: any?,
	Selected: any?, -- membesar permanen (dipakai slot hotbar)
	OnActivated: (() -> ())?,
	Content: { any }?, -- isi custom; kalau ada, Text/Icon diabaikan
}

local function isPointer(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

-- Nama palette final (untuk cari skin di UIAssets.Buttons)
local function paletteName(variant: any): string
	if type(variant) == "string" then
		if Theme.Palettes[variant] then
			return variant
		end
		return Theme.Roles[variant] or Theme.Roles.Primary
	end
	return Theme.Roles.Primary
end

return function(scope: any, props: Props): Instance
	local hovered = scope:Value(false)
	local pressed = scope:Value(false)

	local disabled = scope:Computed(function(use)
		return use(props.Disabled) == true
	end)
	local variant = scope:Computed(function(use)
		if use(disabled) then
			return Theme.Roles.Disabled
		end
		return paletteName(use(props.Variant) or "Primary")
	end)
	local skin = scope:Computed(function(use)
		local s = UIAssets.Buttons[use(variant)]
		return if s and s.Image ~= "" then s else nil
	end)
	local hasSkin = scope:Computed(function(use)
		return use(skin) ~= nil
	end)

	local scale = scope:Spring(
		scope:Computed(function(use)
			if use(disabled) then
				return 1
			elseif use(pressed) then
				return Anim.PressScale
			elseif use(hovered) then
				return Anim.HoverScale
			elseif use(props.Selected) == true then
				return Anim.SelectedScale
			end
			return 1
		end),
		Anim.ButtonSpeed,
		Anim.ButtonDamping
	)
	local sink = scope:Spring(
		scope:Computed(function(use)
			return if use(pressed) and not use(disabled) then Anim.PressSink else 0
		end),
		Anim.ButtonSpeed,
		1
	)

	local content
	if props.Content then
		content = props.Content
	else
		local hasIcon = props.Icon ~= nil
		local hasText = props.Text ~= nil
		content = Style.children(
			scope:New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			hasIcon and Icon(scope, {
				Asset = props.Icon,
				Size = UDim2.fromScale(1, 1),
				LayoutOrder = 1,
			}),
			hasText and Label(scope, {
				Text = props.Text,
				Size = UDim2.fromScale(if hasIcon then 0.7 else 1, 1),
				LayoutOrder = 2,
			})
		)
	end

	return Block(scope, {
		Name = props.Name or "StudButton",
		Size = props.Size or UDim2.fromOffset(180, 56),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		Palette = variant,
		Scale = scale,
		Sink = sink,
		HideDecor = hasSkin,
		Padding = 6,
		FaceClass = "ImageButton",
		FaceProps = {
			AutoButtonColor = false,
			Image = scope:Computed(function(use)
				local s = use(skin)
				return if s then s.Image else ""
			end),
			ScaleType = scope:Computed(function(use)
				local s = use(skin)
				return if s and s.SliceCenter then Enum.ScaleType.Slice else Enum.ScaleType.Stretch
			end),
			SliceCenter = scope:Computed(function(use)
				local s = use(skin)
				return if s and s.SliceCenter then s.SliceCenter else Rect.new(0, 0, 0, 0)
			end),

			[OnEvent("Activated")] = function()
				if not peek(disabled) and props.OnActivated then
					props.OnActivated()
				end
			end,
			[OnEvent("MouseEnter")] = function()
				hovered:set(true)
			end,
			[OnEvent("MouseLeave")] = function()
				hovered:set(false)
				pressed:set(false)
			end,
			[OnEvent("InputBegan")] = function(input: InputObject)
				if isPointer(input) then
					pressed:set(true)
				end
			end,
			[OnEvent("InputEnded")] = function(input: InputObject)
				if isPointer(input) then
					pressed:set(false)
					if input.UserInputType == Enum.UserInputType.Touch then
						hovered:set(false)
					end
				end
			end,
		},
		Content = content,
	})
end
