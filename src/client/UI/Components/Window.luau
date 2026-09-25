--!strict
--[[
	Jendela gaya DonationMenu / Inventory: panel gelap, judul GothamBlack metalik rata kiri,
	garis putih di bawah judul, tombol X metalik. Buka = meluncur dari bawah (Spring).
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Style = require(script.Parent.Parent.Style)
local Panel = require(script.Parent.Panel)
local Text = require(script.Parent.Text)
local Button = require(script.Parent.Button)

local Children = Fusion.Children
local Anim = Theme.Animation

export type Props = {
	Name: string,
	Title: any,
	Open: any, -- boolean (state)
	OnClose: () -> (),
	Size: UDim2,
	Scale: any?, -- skala layar (state)
	HeaderRight: { any }?, -- elemen tambahan di kanan judul (mis. info tas)
	Content: { any },
}

local HEADER_HEIGHT = 48
local CLOSE_SIZE = 28

return function(scope: any, props: Props): Instance
	local isOpen = scope:Computed(function(use)
		return use(props.Open) == true
	end)
	local offsetY = scope:Spring(
		scope:Computed(function(use)
			return if use(isOpen) then 0 else Anim.WindowHiddenOffset
		end),
		Anim.WindowSpeed,
		Anim.WindowDamping
	)

	return scope:New("Frame")({
		Name = props.Name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = scope:Computed(function(use)
			return use(isOpen) or use(offsetY) < Anim.WindowHiddenOffset - 1
		end),

		[Children] = {
			Panel(scope, {
				Name = "MasterFrame",
				Size = props.Size,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = scope:Computed(function(use)
					return UDim2.new(0.5, 0, 0.5, use(offsetY))
				end),
				StrokeThickness = 2,
				Content = {
					scope:New("UIScale")({ Scale = props.Scale or 1 }),

					Text(scope, {
						Name = "Header",
						Text = props.Title,
						Weight = "Black",
						TextSize = Theme.Sizes.TextTitle,
						Metallic = true,
						Size = UDim2.new(0.6, 0, 0, HEADER_HEIGHT),
						Position = UDim2.fromOffset(16, 0),
					}),

					scope:New("Frame")({
						Name = "HeaderRight",
						Size = UDim2.new(0.6, -(CLOSE_SIZE + 24), 0, HEADER_HEIGHT),
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, -(CLOSE_SIZE + 20), 0, 0),
						BackgroundTransparency = 1,
						[Children] = Style.children(
							Style.list(scope, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right),
							props.HeaderRight
						),
					}),

					Button(scope, {
						Name = "CloseBtn",
						Icon = UIAssets.Icons.Close,
						IconSize = 14,
						Size = UDim2.fromOffset(CLOSE_SIZE, CLOSE_SIZE),
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -12, 0, HEADER_HEIGHT / 2),
						Corner = UDim.new(0, 6),
						OnActivated = props.OnClose,
					}),

					-- Garis putih di bawah judul (seperti referensi Inventory)
					scope:New("Frame")({
						Name = "Divider",
						Size = UDim2.new(1, -32, 0, 2),
						Position = UDim2.fromOffset(16, HEADER_HEIGHT - 2),
						BackgroundColor3 = Theme.Colors.Stroke,
						BackgroundTransparency = 0.15,
						BorderSizePixel = 0,
					}),

					scope:New("Frame")({
						Name = "Body",
						Size = UDim2.new(1, 0, 1, -(HEADER_HEIGHT + 8)),
						Position = UDim2.fromOffset(0, HEADER_HEIGHT + 8),
						BackgroundTransparency = 1,
						[Children] = Style.children(Style.padding(scope, 4, 14, 14), props.Content),
					}),
				},
			}),
		},
	})
end
