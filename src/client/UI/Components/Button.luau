--!strict
--[[
	Tombol gaya DonationMenu: abu-abu (63,63,63) + gradient metalik, sudut 10, stroke putih tipis.
	Variant: "Metal" (default), "Ghost" (transparan + stroke), "Dark" (toggle), "Success", "Danger".
	Hover membesar sedikit, tekan mengecil (Spring).
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Style = require(script.Parent.Parent.Style)
local Icon = require(script.Parent.Icon)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek
local Colors = Theme.Colors
local Anim = Theme.Animation

export type Props = {
	Name: string?,
	Text: any?,
	TextSize: number?,
	Icon: any?, -- UIAssets.IconAsset (boleh state)
	IconSize: number?, -- px
	Variant: any?,
	Disabled: any?,
	OnActivated: (() -> ())?,
	Size: any?,
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: any?,
	Corner: UDim?,
}

local VARIANT_COLORS = {
	Metal = Colors.Button,
	Ghost = Colors.Button,
	Dark = Colors.ButtonDark,
	Success = Colors.Success,
	Danger = Colors.Danger,
}

return function(scope: any, props: Props): Instance
	local hovered = scope:Value(false)
	local pressed = scope:Value(false)
	local disabled = scope:Computed(function(use)
		return use(props.Disabled) == true
	end)
	local variant = scope:Computed(function(use)
		return use(props.Variant) or "Metal"
	end)

	local scale = scope:Spring(
		scope:Computed(function(use)
			if use(disabled) then
				return 1
			elseif use(pressed) then
				return Anim.PressScale
			elseif use(hovered) then
				return Anim.HoverScale
			end
			return 1
		end),
		Anim.ButtonSpeed,
		Anim.ButtonDamping
	)
	local contentTransparency = scope:Computed(function(use)
		return if use(disabled) then 0.5 else 0
	end)

	local hasIcon = props.Icon ~= nil
	local hasText = props.Text ~= nil

	return scope:New("TextButton")({
		Name = props.Name or "Button",
		Size = props.Size or UDim2.fromOffset(120, 36),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Visible = props.Visible,
		AutoButtonColor = false,
		Text = "",
		BackgroundColor3 = scope:Computed(function(use)
			return VARIANT_COLORS[use(variant)] or Colors.Button
		end),
		BackgroundTransparency = scope:Computed(function(use)
			local v = use(variant)
			if v == "Ghost" then
				return 1
			end
			if use(disabled) then
				return 0.5
			end
			return if v == "Dark" then 0.1 else 0
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
		[OnEvent("MouseButton1Down")] = function()
			pressed:set(true)
		end,
		[OnEvent("MouseButton1Up")] = function()
			pressed:set(false)
		end,

		[Children] = Style.children(
			scope:New("UIScale")({ Scale = scale }),
			Style.corner(scope, props.Corner),
			Style.metallic(
				scope,
				scope:Computed(function(use)
					local v = use(variant)
					return v == "Metal" or v == "Success" or v == "Danger"
				end)
			),
			Style.stroke(scope, {
				Transparency = scope:Computed(function(use)
					return if use(variant) == "Ghost" then 0.85 else Theme.Transparency.ButtonStroke
				end),
			}),
			scope:New("Frame")({
				Name = "Content",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = props.ZIndex,
				[Children] = Style.children(
					Style.list(scope, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Center),
					hasIcon and Icon(scope, {
						Asset = props.Icon,
						Size = UDim2.fromOffset(props.IconSize or 20, props.IconSize or 20),
						LayoutOrder = 1,
						ZIndex = props.ZIndex,
						Transparency = contentTransparency,
					}),
					hasText and scope:New("TextLabel")({
						Name = "Label",
						LayoutOrder = 2,
						Size = UDim2.fromScale(0, 1),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = 1,
						Text = props.Text,
						FontFace = Theme.Fonts.Bold,
						TextSize = props.TextSize or Theme.Sizes.TextBody,
						TextColor3 = Colors.Text,
						ZIndex = props.ZIndex,
						TextTransparency = contentTransparency,
					})
				),
			})
		),
	})
end
