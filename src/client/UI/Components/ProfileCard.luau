--!strict
-- Kartu profil gaya Studded (kiri bawah): avatar + lencana level, nama, kapsul uang, bar EXP.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Style = require(script.Parent.Parent.Style)
local Block = require(script.Parent.Block)
local Label = require(script.Parent.Label)
local Icon = require(script.Parent.Icon)
local ProgressBar = require(script.Parent.ProgressBar)

local Children = Fusion.Children
local Profile = Theme.Profile
local Anim = Theme.Animation

export type Props = {
	DisplayName: any,
	UserId: any, -- untuk foto avatar (rbxthumb)
	MoneyText: any, -- "Rp. 907.345"
	LevelText: any, -- "Lv 11"
	ExpText: any, -- "193 / 523"
	ExpProgress: any, -- 0..1
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Scale: any?,
}

local BADGE = 40

return function(scope: any, props: Props): Instance
	local avatar = Profile.AvatarSize
	local contentX = avatar + 14
	local panel = Style.palette(Profile.Palette)

	local bump = scope:Spring(1, Anim.BumpSpeed, Anim.BumpDamping)
	if type(props.MoneyText) == "table" then
		scope:Observer(props.MoneyText):onChange(function()
			bump:setPosition(Anim.BumpScale)
		end)
	end

	return Block(scope, {
		Name = "ProfileCard",
		Size = UDim2.fromOffset(Profile.Width, Profile.Height),
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 1),
		Position = props.Position,
		Palette = Profile.Palette,
		CornerRadius = Theme.Sizes.PanelCorner,
		Scale = props.Scale,
		Padding = 10,
		Content = {
			-- Avatar bulat dengan outline gelap
			scope:New("ImageLabel")({
				Name = "Avatar",
				Size = UDim2.fromOffset(avatar, avatar),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				ZIndex = 3,
				Image = scope:Computed(function(use)
					local userId = use(props.UserId) or 1
					return `rbxthumb://type=AvatarHeadShot&id={userId}&w=150&h=150`
				end),
				[Children] = {
					Style.corner(scope, UDim.new(1, 0)),
					Style.outline(scope, panel.Dark),
				},
			}),

			-- Lencana level menempel di pojok avatar
			Block(scope, {
				Name = "LevelBadge",
				Size = UDim2.fromOffset(BADGE + 16, BADGE - 8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, avatar / 2, 1, -6),
				Palette = Profile.BadgePalette,
				CornerRadius = UDim.new(1, 0),
				Studs = false,
				Padding = 3,
				ZIndex = 4,
				Content = {
					Label(scope, { Name = "LevelText", Text = props.LevelText, ZIndex = 5 }),
				},
			}),

			Label(scope, {
				Name = "NameText",
				Text = props.DisplayName,
				Font = Theme.TitleFont,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -contentX, 0, 28),
				Position = UDim2.fromOffset(contentX, 0),
				MaxTextSize = 28,
				ZIndex = 3,
			}),

			Block(scope, {
				Name = "Money",
				Size = UDim2.new(1, -contentX, 0, 30),
				Position = UDim2.fromOffset(contentX, 32),
				Palette = Profile.MoneyPalette,
				CornerRadius = UDim.new(1, 0),
				Scale = bump,
				Padding = 3,
				Content = {
					Icon(scope, {
						Asset = UIAssets.Icons.Wallet,
						Size = UDim2.fromScale(1, 1),
						ZIndex = 5,
					}),
					Label(scope, {
						Name = "MoneyText",
						Text = props.MoneyText,
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = UDim2.new(1, -30, 1, 0),
						Position = UDim2.fromOffset(28, 0),
						ZIndex = 5,
					}),
				},
			}),

			ProgressBar(scope, {
				Name = "ExpBar",
				Progress = props.ExpProgress,
				Text = props.ExpText,
				Size = UDim2.new(1, -contentX, 0, 24),
				Position = UDim2.fromOffset(contentX, 66),
			}),
		},
	})
end
