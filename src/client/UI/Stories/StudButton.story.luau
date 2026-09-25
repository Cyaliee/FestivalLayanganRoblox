local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local StudButton = require(script.Parent.Parent.Components.StudButton)

local controls = {
	Text = "BELI!",
	Variant = "Primary", -- Primary / Secondary / Danger / Gold / Slot
	WithIcon = true,
	Disabled = false,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local clicks = scope:Value(0)

		local button = StudButton(scope, {
			Size = UDim2.fromOffset(220, 66),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Variant = c.Variant,
			Text = scope:Computed(function(use)
				return use(c.Text) .. " (" .. use(clicks) .. ")"
			end),
			Icon = scope:Computed(function(use)
				return if use(c.WithIcon) then UIAssets.Icons.Coin else nil
			end),
			Disabled = c.Disabled,
			OnActivated = function()
				clicks:set(Fusion.peek(clicks) + 1)
			end,
		})
		button.Parent = props.target
	end,
}
