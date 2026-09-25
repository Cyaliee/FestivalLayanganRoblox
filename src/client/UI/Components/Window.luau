--!strict
--[[
	Jendela modal gaya Studded (seperti menu di kit StuddedUI):
	badan putih dengan stud tipis, header berwarna dengan stud, tombol X merah di header,
	outline & bayangan warna gelap dari palette. Muncul dengan efek "pop".
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Style = require(script.Parent.Parent.Style)
local Block = require(script.Parent.Block)
local Label = require(script.Parent.Label)
local StudButton = require(script.Parent.StudButton)

local Children = Fusion.Children
local Anim = Theme.Animation

export type Props = {
	Name: string,
	Title: any,
	Palette: any?, -- warna header/outline (nama palette/role). Default "Secondary"
	Open: any, -- boolean (state)
	OnClose: () -> (),
	Size: UDim2,
	Scale: any?, -- skala layar (state), default 1
	Content: { any },
}

local HEADER_HEIGHT = 64
local CLOSE_SIZE = 44

return function(scope: any, props: Props): Instance
	local accent = props.Palette or "Secondary"
	local isOpen = scope:Computed(function(use)
		return use(props.Open) == true
	end)
	local pop = scope:Spring(
		scope:Computed(function(use)
			return if use(isOpen) then 1 else 0
		end),
		Anim.WindowSpeed,
		scope:Computed(function(use)
			return if use(isOpen) then Anim.WindowOpenDamping else Anim.WindowCloseDamping
		end)
	)

	return scope:New("Frame")({
		Name = props.Name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = scope:Computed(function(use)
			return use(isOpen) or use(pop) > 0.02
		end),

		[Children] = {
			scope:New("Frame")({
				Name = "Backdrop",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Theme.Colors.Backdrop,
				BackgroundTransparency = scope:Computed(function(use)
					return 1 - 0.4 * math.clamp(use(pop), 0, 1)
				end),
				Active = true,
			}),
			Block(scope, {
				Name = "Frame",
				Size = props.Size,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Palette = accent,
				SurfaceColor = Theme.Palettes.White.Surface,
				CornerRadius = Theme.Sizes.PanelCorner,
				Studs = Theme.Studs.PanelTransparency,
				Scale = scope:Computed(function(use)
					return math.max(use(pop), 0.001) * (use(props.Scale) or 1)
				end),
				Content = {
					Block(scope, {
						Name = "Top",
						Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
						Palette = accent,
						CornerRadius = Theme.Sizes.PanelCorner,
						Shadow = false,
						Content = {
							Label(scope, {
								Name = "Title",
								Text = props.Title,
								Font = Theme.TitleFont,
								Size = UDim2.new(0.75, 0, 0.6, 0),
								Position = UDim2.fromScale(0.5, 0.5),
								AnchorPoint = Vector2.new(0.5, 0.5),
								MaxTextSize = 40,
								ZIndex = 3,
							}),
							StudButton(scope, {
								Name = "CloseButton",
								Size = UDim2.fromOffset(CLOSE_SIZE, CLOSE_SIZE),
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -12, 0.5, -2),
								Variant = "Danger",
								Icon = UIAssets.Icons.Close,
								OnActivated = props.OnClose,
							}),
						},
					}),
					scope:New("Frame")({
						Name = "Container",
						Size = UDim2.new(1, 0, 1, -HEADER_HEIGHT),
						Position = UDim2.fromOffset(0, HEADER_HEIGHT),
						BackgroundTransparency = 1,
						ZIndex = 3,
						[Children] = props.Content,
					}),
				},
			}),
		},
	})
end
