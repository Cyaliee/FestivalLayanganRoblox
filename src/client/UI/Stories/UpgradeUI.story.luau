local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local TableConfig = require(ReplicatedStorage.Shared.Config.CraftingTable)
local UpgradeUI = require(script.Parent.Parent.Screens.UpgradeUI)

local controls = {
	Open = true,
	TableLevel = 1,
	Cost = "500",
	CanUpgrade = true,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local open = scope:Value(true)
		scope:Observer(c.Open):onBind(function()
			open:set(Fusion.peek(c.Open))
		end)

		local window = UpgradeUI(scope, {
			Open = open,
			OnClose = function()
				open:set(false)
			end,
			CurrentLevel = c.TableLevel,
			MaxLevel = TableConfig.MaxLevel,
			CostText = c.Cost,
			UpgradeText = UIText.UpgradeButton,
			UpgradeDisabled = scope:Computed(function(use)
				return not use(c.CanUpgrade)
			end),
			OnUpgrade = function()
				print("[Story] Upgrade diklik")
			end,
		})
		window.Parent = props.target
	end,
}
