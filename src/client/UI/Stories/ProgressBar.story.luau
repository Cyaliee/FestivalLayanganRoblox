local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ProgressBar = require(script.Parent.Parent.Components.ProgressBar)

local controls = {
	Progress = 0.45,
	Text = "45 / 100 EXP",
}

return {
	fusion = Fusion,
	controls = controls,
	story = function(props)
		local bar = ProgressBar(props.scope, {
			Size = UDim2.fromOffset(300, 34),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Progress = props.controls.Progress,
			Text = props.controls.Text,
		})
		bar.Parent = props.target
	end,
}
