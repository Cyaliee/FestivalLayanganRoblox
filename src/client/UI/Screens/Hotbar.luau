--!strict
--[[
	Hotbar 1-9 (bawah tengah), pola dari script Hotbar-mu:
	- bar gelap (20,18,26) sudut 14, slot 44px rapat (gap 2), slot aktif menyala
	- tombol paling ujung = show/hide: slot "ditarik masuk" (lebar Spring ke 0),
	  lalu yang tersisa hanya tombol toggle di tengah bawah
	- bar sisa waktu layangan terbang muncul di atasnya
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local HotbarConfig = require(ReplicatedStorage.Shared.Config.Hotbar)
local Style = require(script.Parent.Parent.Style)
local Components = script.Parent.Parent.Components
local ItemSlot = require(Components.ItemSlot)
local Button = require(Components.Button)
local ProgressBar = require(Components.ProgressBar)

local Children = Fusion.Children
local peek = Fusion.peek
local Sizes = Theme.Sizes
local Anim = Theme.Animation

export type Props = {
	Items: any, -- { {Id, Count, IsTool?} } (state)
	Selected: any, -- id item terpilih (state)
	OnSelect: (index: number) -> (),
	Open: any, -- boolean (Value) show/hide
	Scale: any?,
	-- Bar layangan terbang (opsional)
	FlightVisible: any?,
	FlightProgress: any?,
	FlightText: any?,
}

local GAP = 4 -- jarak slot ke tombol toggle

return function(scope: any, props: Props): Instance
	local slotCount = HotbarConfig.SlotCount
	local rowWidth = slotCount * Sizes.SlotSize + (slotCount - 1) * Sizes.SlotGap

	local slots = {}
	for index = 1, slotCount do
		table.insert(
			slots,
			ItemSlot(scope, {
				Name = "Slot" .. index,
				KeyText = tostring(index),
				Transparent = true,
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

	-- Buka/tutup: lebar wrapper Spring ke lebar asli / 0 (+2 buffer supaya ujung slot tidak terpotong)
	local wrapperWidth = scope:Spring(
		scope:Computed(function(use)
			return if use(props.Open) then rowWidth + 2 else 0
		end),
		Anim.CollapseSpeed,
		Anim.CollapseDamping
	)
	local slotsVisible = scope:Value(peek(props.Open) == true)
	scope:Observer(props.Open):onChange(function()
		if peek(props.Open) then
			slotsVisible:set(true)
		else
			task.delay(Anim.CollapseHideDelay, function()
				if not peek(props.Open) then
					slotsVisible:set(false)
				end
			end)
		end
	end)

	local barHeight = Sizes.SlotSize + Sizes.BarPadding * 2

	return scope:New("Frame")({
		Name = "HotbarRoot",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Children] = {
			-- Bar sisa waktu layangan
			ProgressBar(scope, {
				Name = "FlightBar",
				Progress = props.FlightProgress or 0,
				Text = props.FlightText,
				Size = UDim2.fromOffset(260, 16),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -(Sizes.ScreenMargin + barHeight + 10)),
				Visible = props.FlightVisible or false,
				FillColor = Theme.Colors.ExpFill,
			}),

			scope:New("Frame")({
				Name = "Hotbar",
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -Sizes.ScreenMargin),
				Size = UDim2.fromOffset(0, barHeight),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Theme.Colors.Bar,
				BackgroundTransparency = Theme.Transparency.Bar,
				[Children] = {
					scope:New("UIScale")({ Scale = props.Scale or 1 }),
					Style.corner(scope, Sizes.BarCorner),
					Style.padding(scope, Sizes.BarPadding),
					Style.list(scope, Enum.FillDirection.Horizontal, GAP),

					scope:New("Frame")({
						Name = "SlotsWrapper",
						LayoutOrder = 1,
						Size = scope:Computed(function(use)
							return UDim2.fromOffset(use(wrapperWidth), Sizes.SlotSize)
						end),
						ClipsDescendants = true,
						BackgroundTransparency = 1,
						Visible = slotsVisible,
						[Children] = {
							scope:New("Frame")({
								Name = "Slots",
								Size = UDim2.fromOffset(rowWidth, Sizes.SlotSize),
								BackgroundTransparency = 1,
								[Children] = Style.children(
									Style.list(scope, Enum.FillDirection.Horizontal, Sizes.SlotGap),
									slots
								),
							}),
						},
					}),

					Button(scope, {
						Name = "ToggleButton",
						LayoutOrder = 2,
						Variant = "Dark",
						Icon = scope:Computed(function(use)
							return if use(props.Open) then UIAssets.Icons.ArrowDown else UIAssets.Icons.ArrowUp
						end),
						IconSize = 22,
						Size = UDim2.fromOffset(Sizes.SlotSize, Sizes.SlotSize),
						OnActivated = function()
							props.Open:set(not peek(props.Open))
						end,
					}),
				},
			}),
		},
	})
end
