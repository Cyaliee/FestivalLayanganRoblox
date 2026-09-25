local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local InfoUI = require(UI.Screens.InfoUI)

return {
	fusion = Fusion,
	controls = {},
	story = function(props)
		local window = InfoUI(props.scope, { Open = props.scope:Value(true), OnClose = function() end })
		window.Parent = props.target
	end,
}
