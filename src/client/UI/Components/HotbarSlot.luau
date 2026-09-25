--!strict
-- Satu slot hotbar: ikon item, jumlah, tombol keyboard, highlight saat terpilih.
-- Item ber-rarity: warna slot sesuai rarity (Uncommon hijau, Rare biru, Epic ungu, Legendary emas).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)
local StudButton = require(script.Parent.StudButton)
local Label = require(script.Parent.Label)
local Icon = require(script.Parent.Icon)

export type Props = {
	Item: any, -- { Id, Count }? (state)
	KeyText: string,
	Selected: any, -- boolean (state)
	LayoutOrder: number?,
	OnActivated: () -> (),
}

return function(scope: any, props: Props): Instance
	return StudButton(scope, {
		Name = "Slot" .. props.KeyText,
		Size = UDim2.fromOffset(Theme.Sizes.SlotSize, Theme.Sizes.SlotSize),
		LayoutOrder = props.LayoutOrder,
		Variant = scope:Computed(function(use)
			local item = use(props.Item)
			if item == nil then
				return "SlotEmpty"
			end
			local tier = if item.IsTool then nil else ItemKey.rarity(item.Id)
			if tier and tier.Id ~= "Common" then
				return tier.Palette
			end
			return if use(props.Selected) then "SlotSelected" else "Slot"
		end),
		Selected = props.Selected,
		Disabled = false,
		OnActivated = props.OnActivated,
		Content = {
			Icon(scope, {
				Name = "Icon",
				Asset = scope:Computed(function(use)
					local item = use(props.Item)
					return if item then UIAssets.Items[(ItemKey.parse(item.Id))] else nil
				end),
				Size = UDim2.fromScale(0.7, 0.7),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
			}),
			Label(scope, {
				Name = "KeyLabel",
				Text = props.KeyText,
				Size = UDim2.fromScale(0.3, 0.3),
				Position = UDim2.fromOffset(-2, -4),
				ZIndex = 3,
			}),
			Label(scope, {
				Name = "Count",
				Text = scope:Computed(function(use)
					local item = use(props.Item)
					return if item and item.Count > 1 then Format.number(item.Count) else ""
				end),
				Size = UDim2.fromScale(0.7, 0.32),
				Position = UDim2.new(1, 2, 1, 2),
				AnchorPoint = Vector2.new(1, 1),
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 3,
			}),
		},
	})
end
