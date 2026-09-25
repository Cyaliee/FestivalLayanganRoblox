local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Toast = require(script.Parent.Parent.Components.Toast)

local controls = {
	Text = "Tas Penuh!",
	Visible = true,
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local toast = Toast(props.scope, {
			Text = props.controls.Text,
			Visible = props.controls.Visible,
		})
		toast.Parent = props.target
	end,
}
