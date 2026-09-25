local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local CraftUI = require(UI.Screens.CraftUI)

local controls = {
	TableLevel = 1,
	Bamboo = 6,
	Glue = 1,
	Paper = 1,
	GoldenBamboo = 3,
	ParachuteCloth = 10,
	SuperGlue = 5,
	Luck = 1,
	DragonActive = false,
	Crafting = false,
	RemainingSeconds = 4,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local window = CraftUI(scope, {
			Open = scope:Value(true),
			OnClose = function() end,
			Inventory = scope:Computed(function(use)
				return {
					Bamboo = use(c.Bamboo),
					Glue = use(c.Glue),
					Paper = use(c.Paper),
					GoldenBamboo = use(c.GoldenBamboo),
					ParachuteCloth = use(c.ParachuteCloth),
					SuperGlue = use(c.SuperGlue),
				}
			end),
			TableLevel = c.TableLevel,
			ActiveRecipe = scope:Computed(function(use)
				return if use(c.Crafting) then "Kite" else ""
			end),
			ActiveEndsAt = scope:Computed(function(use)
				return 1000 + use(c.RemainingSeconds)
			end),
			ServerTime = 1000,
			Luck = c.Luck,
			DragonActive = c.DragonActive,
			OnCraft = function(recipeId, useBooster)
				print("[Story] Rakit", recipeId, "booster:", useBooster)
			end,
		})
		window.Parent = props.target
	end,
}
