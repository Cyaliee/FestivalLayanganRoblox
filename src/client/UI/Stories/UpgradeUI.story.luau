local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local UpgradeUI = require(UI.Screens.UpgradeUI)

local controls = {
	TableLevel = 2,
	Cost = "1.200",
	CanUpgrade = true,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local window = UpgradeUI(scope, {
			Open = scope:Value(true),
			OnClose = function() end,
			CurrentLevel = c.TableLevel,
			MaxLevel = 5,
			CostText = c.Cost,
			InfoText = "Kecepatan rakit x1.25 -> x1.5",
			UpgradeText = "UPGRADE",
			UpgradeDisabled = scope:Computed(function(use)
				return not use(c.CanUpgrade)
			end),
			OnUpgrade = function()
				print("[Story] Upgrade meja")
			end,
		})
		window.Parent = props.target
	end,
}
