--!strict
-- Jendela toko/pengepul untuk satu shop (Config/Shops). Beli atau jual tergantung shop.Type.
-- Tombol hanya kirim intent { ItemId, Mode }; harga & jumlah dihitung server.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = require(ReplicatedStorage.Shared.Config.Items)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local ShopsConfig = require(ReplicatedStorage.Shared.Config.Shops)
local Format = require(ReplicatedStorage.Shared.Util.Format)

local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Label = require(Components.Label)
local Icon = require(Components.Icon)
local StudButton = require(Components.StudButton)
local ListRow = require(Components.ListRow)
local ScrollList = require(Components.ScrollList)
local Style = require(script.Parent.Parent.Style)

export type Props = {
	Shop: ShopsConfig.Shop,
	Open: any,
	OnClose: () -> (),
	Inventory: any, -- { [ItemId]: number } (state)
	Coins: any, -- number (state)
	OnTrade: (itemId: string, mode: string) -> (),
	Scale: any?,
}

local ROW_HEIGHT = 84
local BUTTON_WIDTH = 116

local function row(scope: any, props: Props, entry: ShopsConfig.ShopItem): Instance
	local def = Items[entry.ItemId]
	local isBuy = props.Shop.Type == "Buy"
	local owned = scope:Computed(function(use)
		return use(props.Inventory)[entry.ItemId] or 0
	end)
	local canAfford = scope:Computed(function(use)
		return use(props.Coins) >= entry.Price
	end)
	local hasItem = scope:Computed(function(use)
		return use(owned) > 0
	end)

	local function button(order: number, text: string, mode: string, variant: string, enabled: any)
		return StudButton(scope, {
			Name = mode .. "Button",
			Size = UDim2.fromOffset(BUTTON_WIDTH, 42),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -(order - 1) * (BUTTON_WIDTH + 10), 0.5, -2),
			Variant = variant,
			Text = text,
			Disabled = scope:Computed(function(use)
				return not use(enabled)
			end),
			OnActivated = function()
				props.OnTrade(entry.ItemId, mode)
			end,
		})
	end

	return ListRow(scope, {
		Name = entry.ItemId,
		LayoutOrder = entry.Order,
		Height = ROW_HEIGHT,
		Palette = props.Shop.Palette,
		Content = Style.children(
			Icon(scope, {
				Name = "Icon",
				Asset = UIAssets.Items[entry.ItemId],
				Size = UDim2.fromScale(1, 1),
				ZIndex = 3,
			}),
			Label(scope, {
				Name = "NameText",
				Text = def.DisplayName,
				Size = UDim2.new(0.45, 0, 0.45, 0),
				Position = UDim2.fromScale(0.18, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 3,
			}),
			Icon(scope, {
				Name = "CoinIcon",
				Asset = UIAssets.Icons.Coin,
				Size = UDim2.fromScale(0.34, 0.34),
				Position = UDim2.fromScale(0.18, 0.55),
				ZIndex = 3,
			}),
			Label(scope, {
				Name = "PriceText",
				Text = string.format(UIText.Price, Format.number(entry.Price)),
				Size = UDim2.new(0.12, 0, 0.34, 0),
				Position = UDim2.fromScale(0.25, 0.55),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 3,
			}),
			Label(scope, {
				Name = "OwnedText",
				Text = scope:Computed(function(use)
					return string.format(UIText.Owned, Format.number(use(owned)))
				end),
				Size = UDim2.new(0.2, 0, 0.3, 0),
				Position = UDim2.fromScale(0.38, 0.57),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 3,
			}),
			if isBuy
				then button(2, UIText.BuyOne, "One", "Primary", canAfford)
				else button(2, UIText.SellOne, "One", "Gold", hasItem),
			if isBuy
				then button(1, string.format(UIText.BuyBulk, ShopsConfig.BulkBuyAmount), "Bulk", "Primary", canAfford)
				else button(1, UIText.SellAll, "All", "Gold", hasItem)
		),
	})
end

return function(scope: any, props: Props): Instance
	local rows = {}
	for _, entry in props.Shop.Items do
		table.insert(rows, row(scope, props, entry))
	end

	return Window(scope, {
		Name = ShopsConfig.screenName(props.Shop.Id),
		Title = props.Shop.Title,
		Palette = props.Shop.Palette,
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(600, 420),
		Content = {
			Style.padding(scope, 14),
			ScrollList(scope, { Content = rows }),
		},
	})
end
