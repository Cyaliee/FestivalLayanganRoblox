--!strict
-- Jendela Rakit Layangan: status meja + daftar resep (dari Config/Recipes).
-- Tombol Rakit hanya kirim { RecipeId }; server cek bahan, level meja, jarak.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = require(ReplicatedStorage.Shared.Config.Items)
local Recipes = require(ReplicatedStorage.Shared.Config.Recipes)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local TableRules = require(ReplicatedStorage.Shared.Rules.CraftingTable)
local Format = require(ReplicatedStorage.Shared.Util.Format)

local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Block = require(Components.Block)
local Label = require(Components.Label)
local Icon = require(Components.Icon)
local StudButton = require(Components.StudButton)
local ListRow = require(Components.ListRow)
local ScrollList = require(Components.ScrollList)
local Style = require(script.Parent.Parent.Style)

export type Props = {
	Open: any,
	OnClose: () -> (),
	Inventory: any, -- state
	TableLevel: any, -- state
	ActiveRecipe: any, -- "" = kosong (state)
	ActiveEndsAt: any, -- waktu server (state)
	ServerTime: any, -- state
	OnCraft: (recipeId: string) -> (),
	Scale: any?,
}

local ROW_HEIGHT = 92
local STATUS_HEIGHT = 44
local PALETTE = "Orange"

local function sortedRecipes(): { Recipes.Recipe }
	local list = {}
	for _, recipe in Recipes do
		table.insert(list, recipe)
	end
	table.sort(list, function(a, b)
		return a.Order < b.Order
	end)
	return list
end

local function requirementText(inventory: { [string]: number }, recipe: Recipes.Recipe): string
	local ids = {}
	for itemId in recipe.Inputs do
		table.insert(ids, itemId)
	end
	table.sort(ids, function(a, b)
		return Items[a].Order < Items[b].Order
	end)
	local parts = {}
	for _, itemId in ids do
		table.insert(
			parts,
			string.format(
				UIText.Requirement,
				recipe.Inputs[itemId],
				Items[itemId].DisplayName,
				Format.number(inventory[itemId] or 0)
			)
		)
	end
	return table.concat(parts, " · ")
end

return function(scope: any, props: Props): Instance
	local busy = scope:Computed(function(use)
		return use(props.ActiveRecipe) ~= ""
	end)

	local statusText = scope:Computed(function(use)
		local recipeId = use(props.ActiveRecipe)
		local recipe = Recipes[recipeId]
		if recipe == nil then
			return UIText.CraftIdle
		end
		local name = Items[recipe.Output].DisplayName
		local remaining = math.ceil(use(props.ActiveEndsAt) - use(props.ServerTime))
		if remaining <= 0 then
			return string.format(UIText.CraftReady, name)
		end
		return string.format(UIText.CraftBusy, name, string.format(UIText.Seconds, remaining))
	end)

	local rows = {}
	for _, recipe in sortedRecipes() do
		local locked = scope:Computed(function(use)
			return use(props.TableLevel) < recipe.RequiredTableLevel
		end)
		local hasMaterials = scope:Computed(function(use)
			return TableRules.hasMaterials(use(props.Inventory), recipe.Id)
		end)

		table.insert(
			rows,
			ListRow(scope, {
				Name = recipe.Id,
				LayoutOrder = recipe.Order,
				Height = ROW_HEIGHT,
				Palette = PALETTE,
				Content = {
					Icon(scope, {
						Name = "Icon",
						Asset = UIAssets.Items[recipe.Output],
						Size = UDim2.fromScale(1, 1),
						ZIndex = 3,
					}),
					Label(scope, {
						Name = "NameText",
						Text = Items[recipe.Output].DisplayName,
						Size = UDim2.new(0.5, 0, 0.36, 0),
						Position = UDim2.fromScale(0.17, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 3,
					}),
					Label(scope, {
						Name = "Requirements",
						Text = scope:Computed(function(use)
							return requirementText(use(props.Inventory), recipe)
						end),
						Size = UDim2.new(0.55, 0, 0.26, 0),
						Position = UDim2.fromScale(0.17, 0.4),
						TextXAlignment = Enum.TextXAlignment.Left,
						MaxTextSize = 18,
						ZIndex = 3,
					}),
					Label(scope, {
						Name = "DurationText",
						Text = scope:Computed(function(use)
							local seconds = TableRules.craftDuration(recipe.Id, use(props.TableLevel))
							return UIAssets.Icons.Clock.Fallback
								.. " "
								.. string.format(UIText.CraftDuration, string.format("%g", math.floor(seconds * 10) / 10))
						end),
						Size = UDim2.new(0.3, 0, 0.24, 0),
						Position = UDim2.fromScale(0.17, 0.72),
						TextXAlignment = Enum.TextXAlignment.Left,
						MaxTextSize = 18,
						ZIndex = 3,
					}),
					StudButton(scope, {
						Name = "CraftButton",
						Size = UDim2.fromOffset(150, 48),
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, 0, 0.5, -2),
						Variant = "Primary",
						Text = scope:Computed(function(use)
							if use(locked) then
								return UIAssets.Icons.Lock.Fallback
									.. " "
									.. string.format(UIText.CraftLocked, recipe.RequiredTableLevel)
							end
							return UIText.CraftButton
						end),
						Disabled = scope:Computed(function(use)
							return use(locked) or use(busy) or not use(hasMaterials)
						end),
						OnActivated = function()
							props.OnCraft(recipe.Id)
						end,
					}),
				},
			})
		)
	end

	return Window(scope, {
		Name = "CraftUI",
		Title = UIText.CraftTitle,
		Palette = PALETTE,
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(620, 440),
		Content = {
			Style.padding(scope, 14),
			Block(scope, {
				Name = "Status",
				Size = UDim2.new(1, 0, 0, STATUS_HEIGHT),
				Palette = scope:Computed(function(use)
					return if use(busy) then PALETTE else "Green"
				end),
				CornerRadius = UDim.new(1, 0),
				Padding = 6,
				Content = {
					Label(scope, { Name = "StatusText", Text = statusText, ZIndex = 3 }),
				},
			}),
			ScrollList(scope, {
				Size = UDim2.new(1, 0, 1, -(STATUS_HEIGHT + 14)),
				Position = UDim2.fromOffset(0, STATUS_HEIGHT + 14),
				Content = rows,
			}),
		},
	})
end
