--!strict
--[[
	Kartu profil (kiri bawah), sesuai sketsa:
	  [ avatar bulat ]  Lv. 1  [ Nama              ]
	                           [ (ikon) Nominal uang ]
	                    [========= bar EXP ==========]
	Tone gelap metalik (bar 20,18,26).
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Style = require(script.Parent.Parent.Style)
local Panel = require(script.Parent.Panel)
local Text = require(script.Parent.Text)
local Icon = require(script.Parent.Icon)
local ProgressBar = require(script.Parent.ProgressBar)

local Children = Fusion.Children
local Colors = Theme.Colors
local Anim = Theme.Animation

export type Props = {
	DisplayName: any,
	UserId: any, -- foto avatar (rbxthumb)
	MoneyText: any, -- "Rp. 907.345"
	LevelText: any, -- "Lv. 1"
	ExpText: any?, -- "193 / 523" (di dalam bar)
	ExpProgress: any, -- 0..1
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Scale: any?,
}

local WIDTH, HEIGHT = 330, 96
local AVATAR = 72
local LEVEL_WIDTH = 52
local INFO_X = 12 + AVATAR + 10 + LEVEL_WIDTH

return function(scope: any, props: Props): Instance
	local bump = scope:Spring(1, Anim.BumpSpeed, Anim.BumpDamping)
	if type(props.MoneyText) == "table" then
		scope:Observer(props.MoneyText):onChange(function()
			bump:setPosition(Anim.BumpScale)
		end)
	end

	return Panel(scope, {
		Name = "ProfileCard",
		Size = UDim2.fromOffset(WIDTH, HEIGHT),
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 1),
		Position = props.Position,
		Color = Colors.Bar,
		Transparency = Theme.Transparency.Bar,
		Corner = Theme.Sizes.BarCorner,
		Content = {
			scope:New("UIScale")({ Scale = props.Scale or 1 }),

			scope:New("ImageLabel")({
				Name = "Avatar",
				Size = UDim2.fromOffset(AVATAR, AVATAR),
				Position = UDim2.fromOffset(12, 8),
				BackgroundColor3 = Colors.PanelSoft,
				Image = scope:Computed(function(use)
					local userId = use(props.UserId) or 1
					return `rbxthumb://type=AvatarHeadShot&id={userId}&w=150&h=150`
				end),
				[Children] = {
					Style.corner(scope, UDim.new(1, 0)),
					Style.stroke(scope, { Thickness = 2, Transparency = Theme.Transparency.PanelStroke }),
				},
			}),

			Text(scope, {
				Name = "LevelText",
				Text = props.LevelText,
				Weight = "Black",
				TextSize = 16,
				Metallic = true,
				Size = UDim2.fromOffset(LEVEL_WIDTH, AVATAR),
				Position = UDim2.fromOffset(12 + AVATAR + 8, 8),
			}),

			-- Kotak nama + uang
			Panel(scope, {
				Name = "InfoBox",
				Size = UDim2.new(1, -(INFO_X + 12), 0, 52),
				Position = UDim2.fromOffset(INFO_X, 10),
				Color = Colors.PanelSoft,
				Corner = UDim.new(0, 8),
				StrokeTransparency = Theme.Transparency.ButtonStroke,
				Content = {
					Style.padding(scope, 4, 10),
					Text(scope, {
						Name = "NameText",
						Text = props.DisplayName,
						Weight = "Bold",
						TextSize = 15,
						Truncate = true,
						Size = UDim2.new(1, 0, 0, 20),
					}),
					scope:New("Frame")({
						Name = "Money",
						Size = UDim2.new(1, 0, 0, 20),
						Position = UDim2.fromOffset(0, 22),
						BackgroundTransparency = 1,
						[Children] = {
							scope:New("UIScale")({ Scale = bump }),
							Panel(scope, {
								Name = "MoneyIconBox",
								Size = UDim2.fromOffset(20, 18),
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.fromScale(0, 0.5),
								Color = Colors.Button,
								Corner = UDim.new(0, 4),
								StrokeTransparency = Theme.Transparency.ButtonStroke,
								Content = {
									Icon(scope, { Asset = UIAssets.Icons.Wallet, Size = UDim2.fromScale(0.85, 0.85), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5) }),
								},
							}),
							Text(scope, {
								Name = "MoneyText",
								Text = props.MoneyText,
								Weight = "Bold",
								TextSize = 14,
								Color = Colors.Money,
								Truncate = true,
								Size = UDim2.new(1, -28, 1, 0),
								Position = UDim2.fromOffset(28, 0),
							}),
						},
					}),
				},
			}),

			ProgressBar(scope, {
				Name = "ExpBar",
				Progress = props.ExpProgress,
				Text = props.ExpText,
				Size = UDim2.new(1, -(12 + AVATAR + 8 + 12), 0, 14),
				Position = UDim2.fromOffset(12 + AVATAR + 8, 70),
			}),
		},
	})
end
