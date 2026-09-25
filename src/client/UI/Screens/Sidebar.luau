--!strict
--[[
	Sidebar kiri (tengah layar): tombol gambar Shop, Inventory, Setting, Information (urut dari atas),
	dan tombol ">" / "<" di sampingnya untuk sembunyikan / tampilkan.
	Sembunyi = lebar bar menyusut ke 0 (Spring + ClipsDescendants), pola sama dengan hotbar.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Style = require(script.Parent.Parent.Style)
local Components = script.Parent.Parent.Components
local Button = require(Components.Button)

local Children = Fusion.Children
local peek = Fusion.peek
local Sizes = Theme.Sizes
local Anim = Theme.Animation

export type Entry = { Name: string, Icon: any, OnActivated: () -> () }

export type Props = {
	Entries: { Entry },
	Open: any, -- boolean (Value)
	Scale: any?,
}

local TOGGLE_SIZE = 36

return function(scope: any, props: Props): Instance
	local count = #props.Entries
	local barWidth = Sizes.SidebarButton + Sizes.BarPadding * 2
	local barHeight = count * Sizes.SidebarButton + (count - 1) * Sizes.SidebarGap + Sizes.BarPadding * 2

	local width = scope:Spring(
		scope:Computed(function(use)
			return if use(props.Open) then barWidth else 0
		end),
		Anim.CollapseSpeed,
		Anim.CollapseDamping
	)

	-- Setelah animasi tutup selesai, benar-benar sembunyikan (supaya tombol tidak bisa diklik)
	local barVisible = scope:Value(peek(props.Open) == true)
	scope:Observer(props.Open):onChange(function()
		if peek(props.Open) then
			barVisible:set(true)
		else
			task.delay(Anim.CollapseHideDelay, function()
				if not peek(props.Open) then
					barVisible:set(false)
				end
			end)
		end
	end)

	local buttons = {}
	for index, entry in props.Entries do
		table.insert(
			buttons,
			Button(scope, {
				Name = entry.Name,
				Icon = entry.Icon,
				IconSize = 32,
				Size = UDim2.fromOffset(Sizes.SidebarButton, Sizes.SidebarButton),
				LayoutOrder = index,
				OnActivated = entry.OnActivated,
			})
		)
	end

	return scope:New("Frame")({
		Name = "Sidebar",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, Sizes.ScreenMargin, 0.5, 0),
		Size = UDim2.fromOffset(0, barHeight),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		[Children] = {
			scope:New("UIScale")({ Scale = props.Scale or 1 }),
			Style.list(scope, Enum.FillDirection.Horizontal, 6),

			scope:New("Frame")({
				Name = "BarWrapper",
				LayoutOrder = 1,
				Size = scope:Computed(function(use)
					return UDim2.fromOffset(use(width), barHeight)
				end),
				ClipsDescendants = true,
				BackgroundTransparency = 1,
				Visible = barVisible,
				[Children] = {
					scope:New("Frame")({
						Name = "Bar",
						Size = UDim2.fromOffset(barWidth, barHeight),
						BackgroundColor3 = Theme.Colors.Bar,
						BackgroundTransparency = Theme.Transparency.Bar,
						[Children] = Style.children(
							Style.corner(scope, Sizes.BarCorner),
							Style.padding(scope, Sizes.BarPadding),
							scope:New("UIListLayout")({
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, Sizes.SidebarGap),
							}),
							buttons
						),
					}),
				},
			}),

			Button(scope, {
				Name = "ToggleButton",
				LayoutOrder = 2,
				Variant = "Dark",
				Icon = scope:Computed(function(use)
					return if use(props.Open) then UIAssets.Icons.ArrowLeft else UIAssets.Icons.ArrowRight
				end),
				IconSize = 18,
				Size = UDim2.fromOffset(TOGGLE_SIZE, TOGGLE_SIZE),
				OnActivated = function()
					props.Open:set(not peek(props.Open))
				end,
			}),
		},
	})
end
