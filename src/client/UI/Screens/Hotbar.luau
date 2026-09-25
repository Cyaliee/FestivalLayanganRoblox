--!strict
-- Hotbar di bawah layar. Jumlah slot & tombol keyboard dari Config/Hotbar.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local HotbarConfig = require(ReplicatedStorage.Shared.Config.Hotbar)
local HotbarSlot = require(script.Parent.Parent.Components.HotbarSlot)
local ProgressBar = require(script.Parent.Parent.Components.ProgressBar)

local Children = Fusion.Children
local Sizes = Theme.Sizes

export type Props = {
	Items: any, -- { {Id, Count} } (state)
	Selected: any, -- id item terpilih (state)
	OnSelect: (index: number) -> (),
	Scale: any?,
	-- Bar layangan terbang (opsional)
	FlightVisible: any?,
	FlightProgress: any?,
	FlightText: any?,
}

local FLIGHT_BAR_HEIGHT = 30

return function(scope: any, props: Props): Instance
	local slots = {}
	for index = 1, HotbarConfig.SlotCount do
		table.insert(
			slots,
			HotbarSlot(scope, {
				KeyText = tostring(index),
				LayoutOrder = index,
				Item = scope:Computed(function(use)
					return use(props.Items)[index]
				end),
				Selected = scope:Computed(function(use)
					local item = use(props.Items)[index]
					return item ~= nil and item.Id == use(props.Selected)
				end),
				OnActivated = function()
					props.OnSelect(index)
				end,
			})
		)
	end

	local width = HotbarConfig.SlotCount * (Sizes.SlotSize + Sizes.SlotGap)

	return scope:New("Frame")({
		Name = "Hotbar",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		[Children] = {
			scope:New("Frame")({
				Name = "Slots",
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -Sizes.ScreenMargin),
				Size = UDim2.fromOffset(width, Sizes.SlotSize + Sizes.ShadowOffset),
				BackgroundTransparency = 1,
				[Children] = {
					ProgressBar(scope, {
						Name = "FlightBar",
						Progress = props.FlightProgress or 0,
						Text = props.FlightText,
						Palette = "Kite",
						Size = UDim2.fromOffset(math.min(width, 360), FLIGHT_BAR_HEIGHT),
						AnchorPoint = Vector2.new(0.5, 1),
						Position = UDim2.new(0.5, 0, 0, -14),
						Visible = props.FlightVisible or false,
					}),
					scope:New("UIScale")({ Scale = props.Scale or 1 }),
					scope:New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, Sizes.SlotGap),
					}),
					slots,
				},
			}),
		},
	})
end
