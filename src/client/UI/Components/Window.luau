--!strict
-- Jendela modal: muncul dengan efek "pop", judul di atas, tombol tutup merah.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Panel = require(script.Parent.Panel)
local Label = require(script.Parent.Label)
local StudButton = require(script.Parent.StudButton)

local Children = Fusion.Children
local Anim = Theme.Animation

export type Props = {
	Name: string,
	Title: any,
	Open: any, -- boolean (state)
	OnClose: () -> (),
	Size: UDim2,
	Scale: any?, -- skala layar (state), default 1
	Content: { any },
}

local TITLE_HEIGHT = 50
local CLOSE_SIZE = 50

return function(scope: any, props: Props): Instance
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
			Panel(scope, {
				Name = "Frame",
				Size = props.Size,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Content = {
					scope:New("UIScale")({
						Scale = scope:Computed(function(use)
							return math.max(use(pop), 0.001) * (use(props.Scale) or 1)
						end),
					}),
					Panel(scope, {
						Name = "TitleBar",
						Size = UDim2.new(0.65, 0, 0, TITLE_HEIGHT),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0),
						Palette = Theme.Palettes.Secondary,
						Padding = 6,
						Content = {
							Label(scope, {
								Name = "Title",
								Text = props.Title,
								Font = Theme.TitleFont,
							}),
						},
					}),
					StudButton(scope, {
						Name = "CloseButton",
						Size = UDim2.fromOffset(CLOSE_SIZE, CLOSE_SIZE),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(1, -8, 0, 8),
						Variant = "Danger",
						Icon = UIAssets.Icons.Close,
						OnActivated = props.OnClose,
					}),
					scope:New("Frame")({
						Name = "Body",
						Size = UDim2.new(1, 0, 1, -TITLE_HEIGHT / 2),
						Position = UDim2.fromOffset(0, TITLE_HEIGHT / 2),
						BackgroundTransparency = 1,
						[Children] = props.Content,
					}),
				},
			}),
		},
	})
end
