--!strict
--[[
	Inventory (gaya referensi, tanpa search & sort): grid slot gelap bergaris tipis.
	Klik / tap item -> langsung dipasang ke hotbar (klik lagi -> dilepas). Item yang ada di
	hotbar diberi tanda titik putih. Header: info tas + tombol Upgrade Tas.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Text = require(Components.Text)
local Button = require(Components.Button)
local ItemSlot = require(Components.ItemSlot)
local ScrollList = require(Components.ScrollList)

local Children = Fusion.Children

export type Props = {
	Open: any,
	OnClose: () -> (),
	Inventory: any, -- { [key]: count } (state)
	Hotbar: any, -- { key } (state)
	BagText: any, -- "Tas Lv.1  12 / 20"
	OnToggleHotbar: (key: string) -> (),
	OnUpgradeBag: () -> (),
	Scale: any?,
}

local CELL = 56

return function(scope: any, props: Props): Instance
	local keys = scope:Computed(function(use)
		local list = {}
		for key, count in use(props.Inventory) do
			if count > 0 and ItemKey.isValid(key) then
				table.insert(list, key)
			end
		end
		table.sort(list, function(a, b)
			return ItemKey.sortValue(a) < ItemKey.sortValue(b)
		end)
		return list
	end)

	local slots = scope:ForValues(keys, function(_use, innerScope, key: string)
		return ItemSlot(innerScope, {
			Name = key,
			Size = CELL,
			LayoutOrder = ItemKey.sortValue(key),
			Item = innerScope:Computed(function(use)
				return { Id = key, Count = use(props.Inventory)[key] or 0 }
			end),
			Marked = innerScope:Computed(function(use)
				return table.find(use(props.Hotbar), key) ~= nil
			end),
			OnActivated = function()
				props.OnToggleHotbar(key)
			end,
		})
	end)

	return Window(scope, {
		Name = "Inventory",
		Title = UIText.InventoryTitle,
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(460, 380),
		HeaderRight = {
			Text(scope, {
				Name = "BagText",
				Text = props.BagText,
				TextSize = Theme.Sizes.TextSmall,
				Color = Theme.Colors.TextDim,
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = 1,
			}),
			Button(scope, {
				Name = "UpgradeBagButton",
				Icon = UIAssets.Icons.Upgrade,
				IconSize = 14,
				Size = UDim2.fromOffset(30, 26),
				Corner = UDim.new(0, 6),
				LayoutOrder = 2,
				OnActivated = props.OnUpgradeBag,
			}),
		},
		Content = {
			Text(scope, {
				Name = "Hint",
				Text = UIText.InventoryHint,
				Weight = "Regular",
				TextSize = Theme.Sizes.TextSmall,
				Color = Theme.Colors.TextMuted,
				Size = UDim2.new(1, 0, 0, 16),
			}),
			Text(scope, {
				Name = "EmptyText",
				Text = UIText.InventoryEmpty,
				Weight = "Regular",
				Color = Theme.Colors.TextMuted,
				XAlignment = Enum.TextXAlignment.Center,
				Wrapped = true,
				Size = UDim2.new(1, 0, 0, 60),
				Position = UDim2.fromOffset(0, 60),
				ZIndex = 3,
				Visible = scope:Computed(function(use)
					return #use(keys) == 0
				end),
			}),
			scope:New("Frame")({
				Name = "GridBox",
				Size = UDim2.new(1, 0, 1, -22),
				Position = UDim2.fromOffset(0, 22),
				BackgroundColor3 = Theme.Colors.PanelSoft,
				BackgroundTransparency = 0.3,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = Theme.Sizes.Corner }),
					ScrollList(scope, {
						Name = "Grid",
						Layout = "Grid",
						CellSize = CELL,
						Gap = 12,
						Content = slots,
						Size = UDim2.new(1, -8, 1, -8),
						Position = UDim2.fromOffset(8, 8),
					}),
				},
			}),
		},
	})
end
