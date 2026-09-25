local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local HotbarSlot = require(script.Parent.Parent.Components.HotbarSlot)

local controls = {
	ItemId = "KiteBiasa", -- kosongkan untuk slot kosong
	Count = 3,
	Selected = false,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local selected = scope:Value(false)
		scope:Observer(c.Selected):onBind(function()
			selected:set(Fusion.peek(c.Selected))
		end)

		local slot = HotbarSlot(scope, {
			KeyText = "1",
			Item = scope:Computed(function(use)
				local id = use(c.ItemId)
				return if id ~= "" then { Id = id, Count = use(c.Count) } else nil
			end),
			Selected = selected,
			OnActivated = function()
				selected:set(not Fusion.peek(selected))
			end,
		})
		slot.Position = UDim2.fromScale(0.5, 0.5)
		slot.AnchorPoint = Vector2.new(0.5, 0.5)
		slot.Parent = props.target
	end,
}
