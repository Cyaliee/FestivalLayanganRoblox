local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local CraftUI = require(script.Parent.Parent.Screens.CraftUI)

local controls = {
	TableLevel = 1,
	Bamboo = 6,
	Glue = 1,
	Paper = 1,
	Cloth = 3,
	Crafting = false, -- tampilkan status sedang merakit
	RemainingSeconds = 4,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local open = scope:Value(true)

		local window = CraftUI(scope, {
			Open = open,
			OnClose = function()
				open:set(false)
			end,
			Inventory = scope:Computed(function(use)
				return { Bamboo = use(c.Bamboo), Glue = use(c.Glue), Paper = use(c.Paper), Cloth = use(c.Cloth) }
			end),
			TableLevel = c.TableLevel,
			ActiveRecipe = scope:Computed(function(use)
				return if use(c.Crafting) then "KiteBiasa" else ""
			end),
			ActiveEndsAt = scope:Computed(function(use)
				return 1000 + use(c.RemainingSeconds)
			end),
			ServerTime = 1000,
			OnCraft = function(recipeId)
				print("[Story] Rakit", recipeId)
			end,
		})
		window.Parent = props.target
	end,
}
