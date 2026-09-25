local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Window = require(script.Parent.Parent.Components.Window)
local Label = require(script.Parent.Parent.Components.Label)

local controls = {
	Title = "TOKO",
	Palette = "Red", -- warna header: Red, Blue, Orange, Green, Purple, Pink, Cyan, Teal, Gold
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

		local window = Window(scope, {
			Name = "Window",
			Title = c.Title,
			Palette = c.Palette,
			Open = open,
			OnClose = function()
				open:set(false)
			end,
			Size = UDim2.fromOffset(480, 360),
			Content = {
				Label(scope, {
					Text = "Isi jendela",
					Size = UDim2.new(1, -40, 0, 40),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
				}),
			},
		})
		window.Parent = props.target
	end,
}
