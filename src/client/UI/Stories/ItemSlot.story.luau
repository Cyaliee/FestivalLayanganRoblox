local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local ItemSlot = require(UI.Components.ItemSlot)

local controls = {
	ItemKey = "Kite@Legendary", -- Bamboo, Kite@Common..Kite@Legendary; kosong = slot kosong
	Count = 3,
	Selected = false,
	Marked = true,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local slot = ItemSlot(scope, {
			Item = scope:Computed(function(use)
				local key = use(c.ItemKey)
				return if key ~= "" then { Id = key, Count = use(c.Count) } else nil
			end),
			Selected = c.Selected,
			Marked = c.Marked,
			KeyText = "1",
			Size = 56,
		})
		slot.Position = UDim2.fromScale(0.5, 0.5)
		slot.AnchorPoint = Vector2.new(0.5, 0.5)
		slot.Parent = props.target
	end,
}
