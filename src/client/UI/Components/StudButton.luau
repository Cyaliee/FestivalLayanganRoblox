--!strict
--[[
	Tombol "timbul" gaya cartoon: bayangan di bawah, membesar saat hover,
	mengecil + turun saat ditekan, lalu membal (Fusion Spring).

	Skin: kalau Config/UIAssets.Buttons[Variant].Image diisi, gambar itu dipakai
	sebagai ImageButton; kalau kosong tombol digambar kode (gradient + outline).
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Style = require(script.Parent.Parent.Style)
local Label = require(script.Parent.Label)
local Icon = require(script.Parent.Icon)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local Anim = Theme.Animation
local SHADOW = Theme.Sizes.ShadowOffset

export type Props = {
	Name: string?,
	Size: any?,
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
	Variant: any?, -- nama palette di UITheme.Palettes (boleh state). Default "Primary"
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

return function(scope: any, props: Props): Instance
	local hovered = scope:Value(false)
	local pressed = scope:Value(false)

	local disabled = scope:Computed(function(use)
		return use(props.Disabled) == true
	end)
	local variant = scope:Computed(function(use)
		return use(props.Variant) or "Primary"
	end)
	local palette = scope:Computed(function(use)
		if use(disabled) then
			return Theme.Palettes.Disabled
		end
		return Theme.Palettes[use(variant)] or Theme.Palettes.Primary
	end)
	local skin = scope:Computed(function(use)
		local s = UIAssets.Buttons[use(variant)]
		return if s and not use(disabled) then s else nil
	end)
	local hasSkin = scope:Computed(function(use)
		local s = use(skin)
		return s ~= nil and s.Image ~= ""
	end)
	local drawn = scope:Computed(function(use)
		return not use(hasSkin)
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
			return if use(pressed) and not use(disabled) then SHADOW else 0
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
			Style.padding(scope, 6),
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

	return scope:New("Frame")({
		Name = props.Name or "StudButton",
		Size = props.Size or UDim2.fromOffset(180, 56),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1,

		[Children] = {
			scope:New("UIScale")({ Scale = scale }),

			-- Bayangan bawah (bagian "timbul")
			scope:New("Frame")({
				Name = "Shadow",
				Size = UDim2.new(1, 0, 1, -SHADOW),
				Position = UDim2.fromOffset(0, SHADOW),
				BackgroundColor3 = scope:Computed(function(use)
					return use(palette)[3]
				end),
				Visible = drawn,
				[Children] = {
					Style.corner(scope),
					Style.outline(scope),
				},
			}),

			-- Muka tombol
			scope:New("ImageButton")({
				Name = "Face",
				Size = UDim2.new(1, 0, 1, -SHADOW),
				Position = scope:Computed(function(use)
					return UDim2.fromOffset(0, use(sink))
				end),
				AutoButtonColor = false,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = scope:Computed(function(use)
					return if use(hasSkin) then 1 else 0
				end),
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

				[Children] = Style.children(
					Style.corner(scope),
					Style.outline(scope, drawn),
					Style.gradient(scope, palette, drawn),
					scope:New("Frame")({
						Name = "Content",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						[Children] = content,
					})
				),
			}),
		},
	})
end
