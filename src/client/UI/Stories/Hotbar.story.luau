local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local PlayerView = require(UI.Parent.State.PlayerView)
local Hotbar = require(UI.Screens.Hotbar)

local controls = {
	Bamboo = 12,
	KiteCommon = 2,
	KiteEpic = 1,
	KiteLegendary = 1,
	Flying = true,
	FlightProgress = 0.7,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local selected = scope:Value(nil)
		local items = scope:Computed(function(use)
			return PlayerView.hotbarItems({
				Bamboo = use(c.Bamboo),
				["Kite@Common"] = use(c.KiteCommon),
				["Kite@Epic"] = use(c.KiteEpic),
				["Kite@Legendary"] = use(c.KiteLegendary),
			}, { "Bamboo", "Kite@Common", "Kite@Epic", "Kite@Legendary" })
		end)
		local hotbar = Hotbar(scope, {
			Items = items,
			Selected = selected,
			Open = scope:Value(true),
			OnSelect = function(index)
				local item = Fusion.peek(items)[index]
				if item then
					selected:set(if Fusion.peek(selected) == item.Id then nil else item.Id)
				end
			end,
			FlightVisible = c.Flying,
			FlightProgress = c.FlightProgress,
			FlightText = "Layangan (Epic) - 42s",
		})
		hotbar.Parent = props.target
	end,
}
