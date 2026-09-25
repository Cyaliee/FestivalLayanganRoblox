--!strict
-- Jendela Rakit Layangan: status meja + daftar resep (dari Config/Recipes).
-- Tombol Rakit hanya kirim { RecipeId, UseBooster }; server cek bahan, level meja, jarak,
-- dan mengacak rarity saat selesai.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Items = require(ReplicatedStorage.Shared.Config.Items)
local RarityConfig = require(ReplicatedStorage.Shared.Config.Rarity)
local Rarity = require(ReplicatedStorage.Shared.Rules.Rarity)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)
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
	OnCraft: (recipeId: string, useBooster: boolean) -> (),
	Luck: any?, -- pengali luck pemain (state), untuk menampilkan peluang
	DragonActive: any?, -- Aura Naga aktif di kavling (state) -> crafting lebih cepat
	Scale: any?,
}

local ROW_HEIGHT = 118
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
	return table.concat(parts, " · ")
end

local function percent(value: number): string
	local pct = value * 100
	local text = if pct >= 1 then string.format("%.0f", pct) else string.format("%.1f", pct)
	return (string.gsub(text, "%.", ","))
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
		local name = ItemKey.displayName(recipe.Output)
		local remaining = math.ceil(use(props.ActiveEndsAt) - use(props.ServerTime))
		if remaining <= 0 then
			return string.format(UIText.CraftReady, name)
		end
		return string.format(UIText.CraftBusy, name, string.format(UIText.Seconds, remaining))
	end)

	local rows = {}
	for _, recipe in sortedRecipes() do
		local requiredLevel = TableRules.requiredLevel(recipe.Id)
		local useBooster = scope:Value(false)
		local locked = scope:Computed(function(use)
			return use(props.TableLevel) < requiredLevel
		end)
		local hasMaterials = scope:Computed(function(use)
			return TableRules.hasMaterials(use(props.Inventory), recipe.Id, use(useBooster))
		end)

		-- Info rarity: resep tetap ("Selalu Mythic") atau peluang Legendary (luck & booster)
		local rarityText = scope:Computed(function(use)
			if recipe.FixedRarity then
				return string.format(UIText.FixedRarity, RarityConfig.Tiers[recipe.FixedRarity].DisplayName)
			end
			if not Items[recipe.Output].HasRarity then
				return ""
			end
			local chances = Rarity.chances(use(props.Luck) or 1, use(useBooster))
			return string.format(UIText.LegendaryChance, percent(chances.Legendary))
		end)

		local content = {
			Icon(scope, {
				Name = "Icon",
				Asset = UIAssets.Items[recipe.Output],
				Size = UDim2.fromScale(1, 1),
				ZIndex = 3,
			}),
			Label(scope, {
				Name = "NameText",
				Text = Items[recipe.Output].DisplayName,
				Size = UDim2.new(0.45, 0, 0.28, 0),
				Position = UDim2.fromScale(0.15, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 3,
			}),
			Label(scope, {
				Name = "Requirements",
				Text = scope:Computed(function(use)
					return requirementText(use(props.Inventory), TableRules.cost(recipe.Id, use(useBooster)))
				end),
				Size = UDim2.new(0.58, 0, 0.2, 0),
				Position = UDim2.fromScale(0.15, 0.32),
				TextXAlignment = Enum.TextXAlignment.Left,
				MaxTextSize = 17,
				ZIndex = 3,
			}),
			Label(scope, {
				Name = "RarityText",
				Text = rarityText,
				TextColor = if recipe.FixedRarity then RarityConfig.Tiers[recipe.FixedRarity].Color else nil,
				Size = UDim2.new(0.4, 0, 0.2, 0),
				Position = UDim2.fromScale(0.15, 0.55),
				TextXAlignment = Enum.TextXAlignment.Left,
				MaxTextSize = 17,
				ZIndex = 3,
			}),
			Label(scope, {
				Name = "DurationText",
				Text = scope:Computed(function(use)
					local seconds =
						TableRules.craftDuration(recipe.Id, use(props.TableLevel), use(props.DragonActive) == true)
					return UIAssets.Icons.Clock.Fallback
						.. " "
						.. string.format(UIText.CraftDuration, string.format("%g", math.floor(seconds * 10) / 10))
				end),
				Size = UDim2.new(0.3, 0, 0.2, 0),
				Position = UDim2.fromScale(0.15, 0.78),
				TextXAlignment = Enum.TextXAlignment.Left,
				MaxTextSize = 17,
				ZIndex = 3,
			}),
			StudButton(scope, {
				Name = "CraftButton",
				Size = UDim2.fromOffset(150, 46),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 2),
				Variant = "Primary",
				Text = scope:Computed(function(use)
					if use(locked) then
						return UIAssets.Icons.Lock.Fallback .. " " .. string.format(UIText.CraftLocked, requiredLevel)
					end
					return UIText.CraftButton
				end),
				Disabled = scope:Computed(function(use)
					return use(locked) or use(busy) or not use(hasMaterials)
				end),
				OnActivated = function()
					props.OnCraft(recipe.Id, Fusion.peek(useBooster))
				end,
			}),
		}

		if recipe.Booster then
			table.insert(
				content,
				StudButton(scope, {
					Name = "BoosterButton",
					Size = UDim2.fromOffset(150, 40),
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.new(1, 0, 1, -6),
					Variant = scope:Computed(function(use)
						return if use(useBooster) then "Gold" else "Secondary"
					end),
					Text = scope:Computed(function(use)
						return if use(useBooster) then UIText.BoosterOn else UIText.BoosterOff
					end),
					OnActivated = function()
						useBooster:set(not Fusion.peek(useBooster))
					end,
				})
			)
		end

		table.insert(
			rows,
			ListRow(scope, {
				Name = recipe.Id,
				LayoutOrder = recipe.Order,
				Height = ROW_HEIGHT,
				Palette = if recipe.FixedRarity then RarityConfig.Tiers[recipe.FixedRarity].Palette else PALETTE,
				Content = content,
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
