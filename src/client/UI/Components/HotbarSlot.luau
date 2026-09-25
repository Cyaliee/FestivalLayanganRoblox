--!strict
-- Satu slot hotbar: ikon item, jumlah, tombol keyboard, highlight saat terpilih.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Format = require(ReplicatedStorage.Shared.Util.Format)
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
	local isEmpty = scope:Computed(function(use)
		return use(props.Item) == nil
	end)

	return StudButton(scope, {
		Name = "Slot" .. props.KeyText,
		Size = UDim2.fromOffset(Theme.Sizes.SlotSize, Theme.Sizes.SlotSize + Theme.Sizes.ShadowOffset),
		LayoutOrder = props.LayoutOrder,
		Variant = scope:Computed(function(use)
			if use(isEmpty) then
				return "SlotEmpty"
			end
			return if use(props.Selected) then "Gold" else "Slot"
		end),
		Selected = props.Selected,
		Disabled = false,
		OnActivated = props.OnActivated,
		Content = {
			Icon(scope, {
				Name = "Icon",
				Asset = scope:Computed(function(use)
					local item = use(props.Item)
					return if item then UIAssets.Items[item.Id] else nil
				end),
				Size = UDim2.fromScale(0.7, 0.7),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
			}),
			Label(scope, {
				Name = "KeyLabel",
				Text = props.KeyText,
				Size = UDim2.fromScale(0.3, 0.3),
				Position = UDim2.fromOffset(4, 2),
				ZIndex = 2,
			}),
			Label(scope, {
				Name = "Count",
				Text = scope:Computed(function(use)
					local item = use(props.Item)
					return if item and item.Count > 1 then Format.number(item.Count) else ""
				end),
				Size = UDim2.fromScale(0.7, 0.32),
				Position = UDim2.new(1, -4, 1, -2),
				AnchorPoint = Vector2.new(1, 1),
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 2,
			}),
		},
	})
end
