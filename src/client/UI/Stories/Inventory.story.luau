local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local Inventory = require(UI.Screens.Inventory)

local controls = {
	Bamboo = 12,
	GoldenBamboo = 1,
	Glue = 3,
	KiteCommon = 2,
	KiteLegendary = 1,
	Naga = 1,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local hotbar = scope:Value({ "Kite@Common" })
		local window = Inventory(scope, {
			Open = scope:Value(true),
			OnClose = function() end,
			Inventory = scope:Computed(function(use)
				return {
					Bamboo = use(c.Bamboo),
					GoldenBamboo = use(c.GoldenBamboo),
					Glue = use(c.Glue),
					["Kite@Common"] = use(c.KiteCommon),
					["Kite@Legendary"] = use(c.KiteLegendary),
					["Naga@Mythic"] = use(c.Naga),
				}
			end),
			Hotbar = hotbar,
			BagText = "Tas Lv.3  19 / 30",
			OnToggleHotbar = function(key)
				local list = table.clone(Fusion.peek(hotbar))
				local index = table.find(list, key)
				if index then
					table.remove(list, index)
				else
					table.insert(list, key)
				end
				hotbar:set(list)
			end,
			OnUpgradeBag = function()
				print("[Story] Upgrade tas")
			end,
		})
		window.Parent = props.target
	end,
}
