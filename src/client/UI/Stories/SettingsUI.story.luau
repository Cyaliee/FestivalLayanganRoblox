local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local SettingsUI = require(UI.Screens.SettingsUI)

return {
	fusion = Fusion,
	controls = {},
	story = function(props)
		local scope = props.scope
		local values = scope:Value({ ShowNametags = true, Music = false, UIScale = "Normal" })
		local window = SettingsUI(scope, {
			Open = scope:Value(true),
			OnClose = function() end,
			Values = values,
			OnChange = function(key, value)
				local copy = table.clone(Fusion.peek(values))
				copy[key] = value
				values:set(copy)
			end,
		})
		window.Parent = props.target
	end,
}
