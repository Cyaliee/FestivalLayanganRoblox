--!strict
--[[
	Jendela Rakit Layangan: status meja + kartu resep (Config/Recipes), tone gelap metalik.
	Tombol RAKIT hanya kirim { RecipeId, UseBooster }; server cek bahan, level meja, jarak,
	dan mengacak rarity saat selesai. Booster Bambu Emas = saklar per resep.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Items = require(ReplicatedStorage.Shared.Config.Items)
local Recipes = require(ReplicatedStorage.Shared.Config.Recipes)
local RarityConfig = require(ReplicatedStorage.Shared.Config.Rarity)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local TableRules = require(ReplicatedStorage.Shared.Rules.CraftingTable)
local Rarity = require(ReplicatedStorage.Shared.Rules.Rarity)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)
local Format = require(ReplicatedStorage.Shared.Util.Format)

local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Panel = require(Components.Panel)
local Text = require(Components.Text)
local Icon = require(Components.Icon)
local Button = require(Components.Button)
local Toggle = require(Components.Toggle)
local ItemSlot = require(Components.ItemSlot)
local ScrollList = require(Components.ScrollList)

local Children = Fusion.Children
local peek = Fusion.peek
local Colors = Theme.Colors

export type Props = {
	Open: any,
	OnClose: () -> (),
	Inventory: any, -- state
	TableLevel: any, -- state
	ActiveRecipe: any, -- "" = kosong (state)
	ActiveEndsAt: any, -- waktu server (state)
	ServerTime: any, -- state
	Luck: any?, -- state
	DragonActive: any?, -- state
	OnCraft: (recipeId: string, useBooster: boolean) -> (),
	Scale: any?,
}

local CARD_HEIGHT = 118
local STATUS_HEIGHT = 32

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

local function requirementText(inventory: { [string]: number }, cost: { [string]: number }): string
	local ids = {}
	for itemId in cost do
		table.insert(ids, itemId)
	end
	table.sort(ids, function(a, b)
		return ItemKey.sortValue(a) < ItemKey.sortValue(b)
	end)
	local parts = {}
	for _, itemId in ids do
		table.insert(
			parts,
			string.format(
				UIText.Requirement,
				cost[itemId],
				ItemKey.displayName(itemId),
				Format.number(inventory[itemId] or 0)
			)
		)
	end
	return table.concat(parts, "  |  ")
end

local function percent(value: number): string
	local pct = value * 100
	local text = if pct >= 1 then string.format("%.0f", pct) else string.format("%.1f", pct)
	return (string.gsub(text, "%.", ","))
end

local function recipeCard(scope: any, props: Props, recipe: Recipes.Recipe, busy: any): Instance
	local requiredLevel = TableRules.requiredLevel(recipe.Id)
	local useBooster = scope:Value(false)
	local locked = scope:Computed(function(use)
		return use(props.TableLevel) < requiredLevel
	end)
	local hasMaterials = scope:Computed(function(use)
		return TableRules.hasMaterials(use(props.Inventory), recipe.Id, use(useBooster))
	end)
	local fixedTier = if recipe.FixedRarity then RarityConfig.Tiers[recipe.FixedRarity] else nil

	local rarityText = scope:Computed(function(use)
		if fixedTier then
			return string.format(UIText.FixedRarity, fixedTier.DisplayName)
		end
		if not Items[recipe.Output].HasRarity then
			return ""
		end
		local chances = Rarity.chances(use(props.Luck) or 1, use(useBooster))
		return string.format(UIText.LegendaryChance, percent(chances.Legendary))
	end)

	local content: { any } = {
		ItemSlot(scope, {
			Name = "OutputSlot",
			Item = { Id = ItemKey.make(recipe.Output, recipe.FixedRarity), Count = recipe.OutputAmount },
			Size = 64,
		}),
		Text(scope, {
			Name = "NameText",
			Text = Items[recipe.Output].DisplayName,
			Weight = "Black",
			TextSize = 15,
			Metallic = true,
			Size = UDim2.new(1, -(80 + 110), 0, 20),
			Position = UDim2.fromOffset(76, 0),
		}),
		Text(scope, {
			Name = "Requirements",
			Text = scope:Computed(function(use)
				return requirementText(use(props.Inventory), TableRules.cost(recipe.Id, use(useBooster)))
			end),
			Weight = "Regular",
			TextSize = 11,
			Color = Colors.TextDim,
			Wrapped = true,
			YAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, -(80 + 110), 0, 30),
			Position = UDim2.fromOffset(76, 22),
		}),
		Text(scope, {
			Name = "RarityText",
			Text = rarityText,
			TextSize = 11,
			Color = if fixedTier then fixedTier.Color else Colors.TextDim,
			Size = UDim2.new(0.5, 0, 0, 14),
			Position = UDim2.fromOffset(76, 56),
		}),
		Icon(scope, {
			Name = "ClockIcon",
			Asset = UIAssets.Icons.Clock,
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.fromOffset(76, 74),
		}),
		Text(scope, {
			Name = "DurationText",
			Text = scope:Computed(function(use)
				local seconds = TableRules.craftDuration(recipe.Id, use(props.TableLevel), use(props.DragonActive) == true)
				return string.format(UIText.CraftDuration, string.format("%g", math.floor(seconds * 10) / 10))
			end),
			TextSize = 11,
			Color = Colors.TextDim,
			Size = UDim2.fromOffset(60, 14),
			Position = UDim2.fromOffset(94, 74),
		}),
		Button(scope, {
			Name = "CraftButton",
			Size = UDim2.fromOffset(100, 32),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			TextSize = 12,
			Icon = scope:Computed(function(use)
				return if use(locked) then UIAssets.Icons.Lock else nil
			end),
			IconSize = 14,
			Text = scope:Computed(function(use)
				return if use(locked) then string.format(UIText.CraftLocked, requiredLevel) else UIText.CraftButton
			end),
			Disabled = scope:Computed(function(use)
				return use(locked) or use(busy) or not use(hasMaterials)
			end),
			OnActivated = function()
				props.OnCraft(recipe.Id, peek(useBooster))
			end,
		}),
	}

	if recipe.Booster then
		table.insert(
			content,
			scope:New("Frame")({
				Name = "BoosterRow",
				Size = UDim2.fromOffset(170, 24),
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				[Children] = {
					Icon(scope, {
						Asset = UIAssets.Icons.Booster,
						Size = UDim2.fromOffset(18, 18),
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
					}),
					Text(scope, {
						Text = scope:Computed(function(use)
							return if use(useBooster) then UIText.BoosterOn else UIText.BoosterOff
						end),
						TextSize = 10,
						Color = Colors.TextDim,
						Size = UDim2.new(1, -76, 1, 0),
						Position = UDim2.fromOffset(22, 0),
					}),
					Toggle(scope, {
						Value = useBooster,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						OnToggle = function(newValue)
							useBooster:set(newValue)
						end,
					}),
				},
			})
		)
	end

	return Panel(scope, {
		Name = recipe.Id,
		LayoutOrder = recipe.Order,
		Size = UDim2.new(1, 0, 0, CARD_HEIGHT),
		Color = Colors.PanelSoft,
		StrokeColor = if fixedTier then fixedTier.Color else nil,
		StrokeTransparency = if fixedTier then 0.3 else Theme.Transparency.ButtonStroke,
		Padding = 12,
		Content = content,
	})
end

return function(scope: any, props: Props): Instance
	local busy = scope:Computed(function(use)
		return use(props.ActiveRecipe) ~= ""
	end)
	local statusText = scope:Computed(function(use)
		local recipe = Recipes[use(props.ActiveRecipe)]
		if recipe == nil then
			return UIText.CraftIdle
		end
		local name = ItemKey.displayName(recipe.Output)
		local remaining = math.ceil(use(props.ActiveEndsAt) - use(props.ServerTime))
		if remaining <= 0 then
			return string.format(UIText.CraftReady, name)
		end
		return string.format(UIText.CraftBusy, name, string.format(UIText.Seconds, remaining))
	end)

	local cards = {}
	for _, recipe in sortedRecipes() do
		table.insert(cards, recipeCard(scope, props, recipe, busy))
	end

	return Window(scope, {
		Name = "CraftUI",
		Title = UIText.CraftTitle,
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(500, 420),
		Content = {
			Panel(scope, {
				Name = "Status",
				Size = UDim2.new(1, 0, 0, STATUS_HEIGHT),
				Color = Colors.PanelSoft,
				Corner = Theme.Sizes.Corner,
				StrokeTransparency = Theme.Transparency.ButtonStroke,
				Content = {
					Text(scope, {
						Name = "StatusText",
						Text = statusText,
						XAlignment = Enum.TextXAlignment.Center,
						Size = UDim2.fromScale(1, 1),
						Color = scope:Computed(function(use)
							return if use(busy) then Colors.Money else Colors.TextDim
						end),
					}),
				},
			}),
			ScrollList(scope, {
				Size = UDim2.new(1, 0, 1, -(STATUS_HEIGHT + 10)),
				Position = UDim2.fromOffset(0, STATUS_HEIGHT + 10),
				Content = cards,
				Gap = 10,
			}),
		},
	})
end
