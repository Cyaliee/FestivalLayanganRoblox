--!strict
-- Jendela Setting: baris label + saklar (Toggle) atau pilihan (Choice) dari Config/Settings.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local SettingsConfig = require(ReplicatedStorage.Shared.Config.Settings)
local Style = require(script.Parent.Parent.Style)

local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Panel = require(Components.Panel)
local Text = require(Components.Text)
local Button = require(Components.Button)
local Toggle = require(Components.Toggle)

local Children = Fusion.Children

export type Props = {
	Open: any,
	OnClose: () -> (),
	Values: any, -- { [key]: value } (state)
	OnChange: (key: string, value: any) -> (),
	Scale: any?,
}

local ROW_HEIGHT = 44

return function(scope: any, props: Props): Instance
	local list = {}
	for _, setting in SettingsConfig.Settings do
		table.insert(list, setting)
	end
	table.sort(list, function(a, b)
		return a.Order < b.Order
	end)

	local rows = {}
	for _, setting in list do
		local value = scope:Computed(function(use)
			local current = use(props.Values)[setting.Key]
			if current == nil then
				return setting.Default
			end
			return current
		end)

		local control
		if setting.Type == "Toggle" then
			control = Toggle(scope, {
				Value = value,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				OnToggle = function(newValue)
					props.OnChange(setting.Key, newValue)
				end,
			})
		else
			local options = {}
			for index, option in setting.Options or {} do
				table.insert(
					options,
					Button(scope, {
						Name = option,
						LayoutOrder = index,
						Text = option,
						TextSize = 11,
						Size = UDim2.fromOffset(62, 26),
						Corner = UDim.new(0, 6),
						Variant = scope:Computed(function(use)
							return if use(value) == option then "Metal" else "Ghost"
						end),
						OnActivated = function()
							props.OnChange(setting.Key, option)
						end,
					})
				)
			end
			control = scope:New("Frame")({
				Name = "Choices",
				Size = UDim2.new(0.6, 0, 1, 0),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				BackgroundTransparency = 1,
				[Children] = Style.children(
					Style.list(scope, Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Right),
					options
				),
			})
		end

		table.insert(
			rows,
			Panel(scope, {
				Name = setting.Key,
				LayoutOrder = setting.Order,
				Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
				Color = Theme.Colors.PanelSoft,
				StrokeTransparency = Theme.Transparency.ButtonStroke,
				Content = {
					Style.padding(scope, 0, 12),
					Text(scope, {
						Name = "Label",
						Text = setting.Label,
						Size = UDim2.new(0.5, 0, 1, 0),
					}),
					control,
				},
			})
		)
	end

	return Window(scope, {
		Name = "SettingsUI",
		Title = UIText.SettingsTitle,
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(340, 280),
		Content = Style.children(Style.list(scope, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center), rows),
	})
end
