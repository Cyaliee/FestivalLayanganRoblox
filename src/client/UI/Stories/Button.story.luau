local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Button = require(UI.Components.Button)

local controls = {
	Text = "CONFIRM",
	Variant = "Metal", -- Metal / Ghost / Dark / Success / Danger
	WithIcon = false,
	Disabled = false,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local scope = props.scope
		local c = props.controls
		local button = Button(scope, {
			Text = c.Text,
			Variant = c.Variant,
			Icon = scope:Computed(function(use)
				return if use(c.WithIcon) then UIAssets.Icons.Shop else nil
			end),
			Disabled = c.Disabled,
			Size = UDim2.fromOffset(160, 40),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			OnActivated = function()
				print("[Story] Button")
			end,
		})
		button.Parent = props.target
	end,
}
