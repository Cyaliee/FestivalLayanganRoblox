local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PlayerView = require(script.Parent.Parent.Parent.State.PlayerView)
local BagUI = require(script.Parent.Parent.Screens.BagUI)

local controls = {
	BagLevel = 1,
	Coins = 300,
	Bamboo = 12,
	Open = true,
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

		local view = PlayerView.derive(scope, {
			Coins = c.Coins,
			Level = 1,
			Exp = 0,
			BagLevel = c.BagLevel,
			TableLevel = 1,
			Inventory = scope:Computed(function(use)
				return { Bamboo = use(c.Bamboo) }
			end),
		})

		local window = BagUI(scope, {
			Open = open,
			OnClose = function()
				open:set(false)
			end,
			BagLevelText = view.BagLevelText,
			BagUsageText = view.BagUsageText,
			BagNextText = view.BagNextText,
			BagCostText = view.BagCostText,
			BagIsMax = view.BagIsMax,
			BagCanAfford = view.BagCanAfford,
			OnUpgrade = function()
				print("[Story] Upgrade tas diklik")
			end,
		})
		window.Parent = props.target
	end,
}
