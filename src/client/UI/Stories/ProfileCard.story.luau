local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ProfileCard = require(script.Parent.Parent.Components.ProfileCard)
local Format = require(ReplicatedStorage.Shared.Util.Format)

local controls = {
	DisplayName = "Melvin",
	UserId = 1,
	Money = 907345,
	Level = 11,
	Exp = 193,
	ExpNeeded = 523,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local card = ProfileCard(scope, {
			DisplayName = c.DisplayName,
			UserId = c.UserId,
			MoneyText = scope:Computed(function(use)
				return "Rp. " .. Format.number(use(c.Money))
			end),
			LevelText = scope:Computed(function(use)
				return "Lvl " .. use(c.Level)
			end),
			ExpText = scope:Computed(function(use)
				return use(c.Exp) .. " / " .. use(c.ExpNeeded)
			end),
			ExpProgress = scope:Computed(function(use)
				return use(c.Exp) / math.max(use(c.ExpNeeded), 1)
			end),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})
		card.Parent = props.target
	end,
}
