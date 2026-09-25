--!strict
-- Jendela Information: cara bermain (teks dari Config/Info).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Info = require(ReplicatedStorage.Shared.Config.Info)
local Style = require(script.Parent.Parent.Style)

local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Panel = require(Components.Panel)
local Text = require(Components.Text)
local ScrollList = require(Components.ScrollList)

export type Props = {
	Open: any,
	OnClose: () -> (),
	Scale: any?,
}

return function(scope: any, props: Props): Instance
	local sections = {}
	for index, section in Info.Sections do
		table.insert(
			sections,
			Panel(scope, {
				Name = "Section" .. index,
				LayoutOrder = index,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Color = Theme.Colors.PanelSoft,
				StrokeTransparency = Theme.Transparency.ButtonStroke,
				Content = {
					Style.padding(scope, 10, 12),
					Style.list(scope, Enum.FillDirection.Vertical, 4),
					Text(scope, {
						Name = "Title",
						LayoutOrder = 1,
						Text = section.Title,
						Weight = "Black",
						TextSize = 14,
						Metallic = true,
					}),
					Text(scope, {
						Name = "Body",
						LayoutOrder = 2,
						Text = section.Body,
						Weight = "Regular",
						TextSize = 12,
						Color = Theme.Colors.TextDim,
						Wrapped = true,
						YAlignment = Enum.TextYAlignment.Top,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
					}),
				},
			})
		)
	end

	return Window(scope, {
		Name = "InfoUI",
		Title = Info.Title,
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(380, 420),
		Content = {
			ScrollList(scope, { Content = sections, Gap = 8 }),
		},
	})
end
