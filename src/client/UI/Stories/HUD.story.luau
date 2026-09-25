local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PlayerView = require(script.Parent.Parent.Parent.State.PlayerView)
local HUD = require(script.Parent.Parent.Screens.HUD)

local controls = {
	DisplayName = "Melvin",
	UserId = 1,
	Level = 11,
	Exp = 193,
	Coins = 907345,
	Bamboo = 12,
	Kites = 3,
	BagLevel = 1,
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
			BagLevel = c.BagLevel,
			TableLevel = 1,
			Inventory = scope:Computed(function(use)
				return { Bamboo = use(c.Bamboo), ["Kite@Common"] = use(c.Kites) }
			end),
		})

		local hud = HUD(scope, {
			OnBagClick = function()
				print("[Story] Kapsul tas diklik")
			end,
			DisplayName = c.DisplayName,
			UserId = c.UserId,
			MoneyText = view.MoneyText,
			LevelCardText = view.LevelCardText,
			ExpShortText = view.ExpShortText,
			ExpProgress = view.ExpProgress,
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
