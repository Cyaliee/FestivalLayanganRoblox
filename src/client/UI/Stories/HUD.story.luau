local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PlayerView = require(script.Parent.Parent.Parent.State.PlayerView)
local HUD = require(script.Parent.Parent.Screens.HUD)

local controls = {
	Level = 5,
	Exp = 120,
	Coins = 1250,
	Bamboo = 12,
	Kites = 3,
	BagTier = 1,
	Notification = "Kavling berhasil diklaim!",
	ShowNotification = true,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls

		local view = PlayerView.derive(scope, {
			Coins = c.Coins,
			Level = c.Level,
			Exp = c.Exp,
			BagTier = c.BagTier,
			TableLevel = 1,
			Inventory = scope:Computed(function(use)
				return { Bamboo = use(c.Bamboo), KiteBiasa = use(c.Kites) }
			end),
		})

		local hud = HUD(scope, {
			LevelText = view.LevelText,
			ExpProgress = view.ExpProgress,
			ExpText = view.ExpText,
			CoinsText = view.CoinsText,
			BambooText = view.BambooText,
			KiteText = view.KiteText,
			BagText = view.BagText,
			BagFull = view.BagFull,
			NotificationText = c.Notification,
			NotificationVisible = c.ShowNotification,
		})
		hud.Parent = props.target
	end,
}
