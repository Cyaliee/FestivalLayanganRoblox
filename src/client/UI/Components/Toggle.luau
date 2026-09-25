--!strict
-- Saklar on/off (Setting). Knob bergeser dengan Spring.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Style = require(script.Parent.Parent.Style)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

export type Props = {
	Value: any, -- boolean (state)
	OnToggle: (newValue: boolean) -> (),
	Position: any?,
	AnchorPoint: any?,
	LayoutOrder: number?,
}

local WIDTH, HEIGHT, KNOB = 48, 24, 18

return function(scope: any, props: Props): Instance
	local isOn = scope:Computed(function(use)
		return use(props.Value) == true
	end)
	local knobX = scope:Spring(
		scope:Computed(function(use)
			return if use(isOn) then WIDTH - KNOB - 3 else 3
		end),
		30,
		0.8
	)

	return scope:New("TextButton")({
		Name = "Toggle",
		Size = UDim2.fromOffset(WIDTH, HEIGHT),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		AutoButtonColor = false,
		Text = "",
		BackgroundColor3 = scope:Computed(function(use)
			return if use(isOn) then Theme.Colors.Success else Theme.Colors.Button
		end),
		[OnEvent("Activated")] = function()
			props.OnToggle(not peek(isOn))
		end,
		[Children] = {
			Style.corner(scope, UDim.new(1, 0)),
			Style.stroke(scope),
			scope:New("Frame")({
				Name = "Knob",
				Size = UDim2.fromOffset(KNOB, KNOB),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = scope:Computed(function(use)
					return UDim2.new(0, use(knobX), 0.5, 0)
				end),
				BackgroundColor3 = Theme.Colors.Text,
				[Children] = { Style.corner(scope, UDim.new(1, 0)) },
			}),
		},
	})
end
