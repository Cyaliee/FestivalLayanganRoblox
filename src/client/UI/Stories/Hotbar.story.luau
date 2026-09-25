local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PlayerView = require(script.Parent.Parent.Parent.State.PlayerView)
local Hotbar = require(script.Parent.Parent.Screens.Hotbar)

local controls = {
	Bamboo = 12,
	Glue = 4,
	Paper = 4,
	Cloth = 0,
	KiteBiasa = 2,
	KiteNaga = 1,
	Flying = true,
	FlightProgress = 0.7,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local selected = scope:Value(nil) -- id item terpilih

		local items = scope:Computed(function(use)
			return PlayerView.hotbarItems({
				Bamboo = use(c.Bamboo),
				Glue = use(c.Glue),
				Paper = use(c.Paper),
				Cloth = use(c.Cloth),
				KiteBiasa = use(c.KiteBiasa),
				KiteNaga = use(c.KiteNaga),
			})
		end)

		local hotbar = Hotbar(scope, {
			Items = items,
			Selected = selected,
			OnSelect = function(index)
				local item = Fusion.peek(items)[index]
				if item then
					selected:set(if Fusion.peek(selected) == item.Id then nil else item.Id)
				end
			end,
			FlightVisible = c.Flying,
			FlightProgress = c.FlightProgress,
			FlightText = "Layangan Biasa • 45s",
		})
		hotbar.Parent = props.target
	end,
}
