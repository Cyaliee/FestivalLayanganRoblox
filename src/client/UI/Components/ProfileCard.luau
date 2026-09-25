--!strict
-- Kartu profil (kanan bawah): foto avatar bulat, nama, uang, level, dan bar EXP.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Label = require(script.Parent.Label)
local Icon = require(script.Parent.Icon)

local Children = Fusion.Children
local Profile = Theme.Profile
local Anim = Theme.Animation

export type Props = {
	DisplayName: any,
	UserId: any, -- untuk foto avatar (rbxthumb)
	MoneyText: any, -- "Rp. 907.345"
	LevelText: any, -- "Lvl 11"
	ExpText: any, -- "193 / 523"
	ExpProgress: any, -- 0..1
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Scale: any?,
}

return function(scope: any, props: Props): Instance
	local avatar = Profile.AvatarSize
	local contentX = avatar + 18

	local progress = scope:Spring(
		scope:Computed(function(use)
			return math.clamp(use(props.ExpProgress) or 0, 0, 1)
		end),
		Anim.BarSpeed,
		Anim.BarDamping
	)
	local bump = scope:Spring(1, Anim.BumpSpeed, Anim.BumpDamping)
	if type(props.MoneyText) == "table" then
		scope:Observer(props.MoneyText):onChange(function()
			bump:setPosition(Anim.BumpScale)
		end)
	end

	return scope:New("Frame")({
		Name = "ProfileCard",
		Size = UDim2.fromOffset(Profile.Width, Profile.Height),
		AnchorPoint = props.AnchorPoint or Vector2.new(1, 1),
		Position = props.Position,
		BackgroundColor3 = Profile.Panel,
		BackgroundTransparency = Profile.PanelTransparency,

		[Children] = {
			scope:New("UIScale")({ Scale = props.Scale or 1 }),
			scope:New("UICorner")({ CornerRadius = UDim.new(0, 18) }),

			-- Foto avatar bulat dengan cincin warna aksen
			scope:New("ImageLabel")({
				Name = "Avatar",
				Size = UDim2.fromOffset(avatar, avatar),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 6, 0.5, 0),
				BackgroundColor3 = Profile.TrackColor,
				Image = scope:Computed(function(use)
					local userId = use(props.UserId) or 1
					return `rbxthumb://type=AvatarHeadShot&id={userId}&w=150&h=150`
				end),
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
					scope:New("UIStroke")({ Color = Profile.Accent, Thickness = 4 }),
				},
			}),

			Label(scope, {
				Name = "NameText",
				Text = props.DisplayName,
				TextColor = Profile.Accent,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -(contentX + 10), 0, 30),
				Position = UDim2.fromOffset(contentX, 6),
				MaxTextSize = 28,
			}),

			scope:New("Frame")({
				Name = "Money",
				Size = UDim2.new(1, -(contentX + 10), 0, 26),
				Position = UDim2.fromOffset(contentX, 36),
				BackgroundTransparency = 1,
				[Children] = {
					scope:New("UIScale")({ Scale = bump }),
					Icon(scope, {
						Asset = UIAssets.Icons.Wallet,
						Size = UDim2.fromOffset(26, 26),
					}),
					Label(scope, {
						Name = "MoneyText",
						Text = props.MoneyText,
						TextColor = Profile.Money,
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = UDim2.new(1, -32, 1, 0),
						Position = UDim2.fromOffset(32, 0),
						MaxTextSize = 24,
					}),
				},
			}),

			Label(scope, {
				Name = "LevelText",
				Text = props.LevelText,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0.4, 0, 0, 18),
				Position = UDim2.fromOffset(contentX, 64),
				MaxTextSize = 18,
			}),
			Label(scope, {
				Name = "ExpText",
				Text = props.ExpText,
				TextXAlignment = Enum.TextXAlignment.Right,
				Size = UDim2.new(1, -(contentX + 12), 0, 18),
				Position = UDim2.fromOffset(contentX, 64),
				MaxTextSize = 18,
			}),

			scope:New("Frame")({
				Name = "ExpBar",
				Size = UDim2.new(1, -(contentX + 12), 0, 10),
				Position = UDim2.fromOffset(contentX, 84),
				BackgroundColor3 = Profile.TrackColor,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
					scope:New("Frame")({
						Name = "Fill",
						Size = scope:Computed(function(use)
							return UDim2.fromScale(math.max(use(progress), 0), 1)
						end),
						BackgroundColor3 = Profile.Accent,
						[Children] = {
							scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
						},
					}),
				},
			}),
		},
	})
end
