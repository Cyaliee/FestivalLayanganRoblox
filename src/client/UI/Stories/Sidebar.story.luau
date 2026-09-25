local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UI = script.Parent.Parent
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Sidebar = require(UI.Screens.Sidebar)

return {
	fusion = Fusion,
	controls = {},
	story = function(props)
		local scope = props.scope
		local function entry(name, icon)
			return {
				Name = name,
				Icon = icon,
				OnActivated = function()
					print("[Story] Sidebar", name)
				end,
			}
		end
		local sidebar = Sidebar(scope, {
			Open = scope:Value(true),
			Entries = {
				entry("Shop", UIAssets.Icons.Shop),
				entry("Inventory", UIAssets.Icons.Inventory),
				entry("Setting", UIAssets.Icons.Settings),
				entry("Information", UIAssets.Icons.Info),
			},
		})
		sidebar.Parent = props.target
	end,
}
