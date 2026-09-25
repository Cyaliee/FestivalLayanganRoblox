--!strict
-- Kapsul status (ikon + angka) gaya Studded. Membal saat angkanya berubah.
-- Kalau OnActivated diisi, kapsul bisa diklik dan muncul lencana "+".
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Block = require(script.Parent.Block)
local Label = require(script.Parent.Label)
local Icon = require(script.Parent.Icon)

local OnEvent = Fusion.OnEvent

local Anim = Theme.Animation
local Sizes = Theme.Sizes

export type Props = {
	Name: string?,
	Icon: any,
	Text: any,
	Palette: any?, -- nama palette/role (boleh state)
	LayoutOrder: number?,
	Position: any?,
	OnActivated: (() -> ())?,
}

local BADGE_SIZE = 26

return function(scope: any, props: Props): Instance
	local bump = scope:Spring(1, Anim.BumpSpeed, Anim.BumpDamping)
	if type(props.Text) == "table" then
		scope:Observer(props.Text):onChange(function()
			bump:setPosition(Anim.BumpScale)
		end)
	end

	local clickable = props.OnActivated ~= nil
	local hovered = scope:Value(false)
	local hover = scope:Spring(
		scope:Computed(function(use)
			return if use(hovered) then Anim.HoverScale else 1
		end),
		Anim.ButtonSpeed,
		Anim.ButtonDamping
	)

	local content: { any } = {
		Icon(scope, {
			Asset = props.Icon,
			Size = UDim2.fromOffset(Sizes.PillHeight + 10, Sizes.PillHeight + 10),
			Position = UDim2.new(0, -12, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			ZIndex = 3,
		}),
		Label(scope, {
			Text = props.Text,
			Size = UDim2.new(1, -(Sizes.PillHeight + 8 + (if clickable then BADGE_SIZE else 0)), 0.75, 0),
			Position = UDim2.new(0, Sizes.PillHeight + 2, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
		}),
	}
	if clickable then
		table.insert(
			content,
			Block(scope, {
				Name = "PlusBadge",
				Size = UDim2.fromOffset(BADGE_SIZE, BADGE_SIZE),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(1, -BADGE_SIZE / 2 - 4, 0.5, -2),
				CornerRadius = UDim.new(1, 0),
				Palette = "Primary",
				Studs = false,
				Content = {
					Label(scope, { Text = "+", Size = UDim2.fromScale(1, 1.1), ZIndex = 3 }),
				},
			})
		)
	end

	return Block(scope, {
		Name = props.Name or "StatPill",
		Size = UDim2.fromOffset(Sizes.PillWidth, Sizes.PillHeight),
		Position = props.Position,
		LayoutOrder = props.LayoutOrder,
		CornerRadius = UDim.new(1, 0),
		Palette = props.Palette,
		Scale = scope:Computed(function(use)
			return use(bump) * use(hover)
		end),
		FaceClass = if clickable then "ImageButton" else "Frame",
		FaceProps = if clickable
			then {
				AutoButtonColor = false,
				[OnEvent("Activated")] = props.OnActivated,
				[OnEvent("MouseEnter")] = function()
					hovered:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					hovered:set(false)
				end,
			}
			else nil,
		Content = content,
	})
end
