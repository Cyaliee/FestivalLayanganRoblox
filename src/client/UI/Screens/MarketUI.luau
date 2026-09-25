--!strict
--[[
	Jendela NPC Pasar (Pengepul / Toko / Tengkulak), satu per shop di Config/Shops.
	Beli atau jual tergantung shop.Type. Tombol hanya kirim intent { ItemKey, Mode };
	harga & jumlah dihitung server. Layangan tampil per rarity (bingkai warna rarity).
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local ShopsConfig = require(ReplicatedStorage.Shared.Config.Shops)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Panel = require(Components.Panel)
local Text = require(Components.Text)
local Icon = require(Components.Icon)
local Button = require(Components.Button)
local ItemSlot = require(Components.ItemSlot)
local ScrollList = require(Components.ScrollList)

local Children = Fusion.Children

export type Props = {
	Shop: ShopsConfig.Shop,
	Open: any,
	OnClose: () -> (),
	Inventory: any, -- state
	Coins: any, -- state
	OnTrade: (itemKey: string, mode: string) -> (),
	Scale: any?,
}

local ROW_HEIGHT = 64
local BUTTON_WIDTH = 92

local function row(scope: any, props: Props, entry: ShopsConfig.ShopItem): Instance
	local key = entry.ItemKey
	local tier = ItemKey.rarity(key)
	local isBuy = props.Shop.Type == "Buy"
	local owned = scope:Computed(function(use)
		return use(props.Inventory)[key] or 0
	end)
	local enabled = scope:Computed(function(use)
		return if isBuy then use(props.Coins) >= entry.Price else use(owned) > 0
	end)

	local function button(order: number, text: string, mode: string)
		return Button(scope, {
			Name = mode .. "Button",
			Text = text,
			TextSize = 11,
			Size = UDim2.fromOffset(BUTTON_WIDTH, 28),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -(8 + (order - 1) * (BUTTON_WIDTH + 6)), 0.5, 0),
			Disabled = scope:Computed(function(use)
				return not use(enabled)
			end),
			OnActivated = function()
				props.OnTrade(key, mode)
			end,
		})
	end

	return Panel(scope, {
		Name = key,
		LayoutOrder = entry.Order,
		Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
		Color = Theme.Colors.PanelSoft,
		StrokeTransparency = Theme.Transparency.ButtonStroke,
		Content = {
			scope:New("Frame")({
				Name = "SlotHolder",
				Size = UDim2.fromOffset(48, 48),
				Position = UDim2.fromOffset(8, 8),
				BackgroundTransparency = 1,
				[Children] = {
					ItemSlot(scope, { Item = { Id = key, Count = 1 }, Size = 48 }),
				},
			}),
			Text(scope, {
				Name = "NameText",
				Text = ItemKey.displayName(key),
				Weight = "Bold",
				TextSize = 13,
				Color = if tier and tier.Id ~= "Common" then tier.Color else nil,
				Truncate = true,
				Size = UDim2.new(1, -(64 + BUTTON_WIDTH * 2 + 24), 0, 18),
				Position = UDim2.fromOffset(64, 10),
			}),
			Icon(scope, {
				Name = "CoinIcon",
				Asset = UIAssets.Icons.Coin,
				Size = UDim2.fromOffset(14, 14),
				Position = UDim2.fromOffset(64, 34),
			}),
			Text(scope, {
				Name = "PriceText",
				Text = Format.number(entry.Price),
				TextSize = 12,
				Color = Theme.Colors.Money,
				Size = UDim2.fromOffset(60, 14),
				Position = UDim2.fromOffset(82, 34),
			}),
			Text(scope, {
				Name = "OwnedText",
				Text = scope:Computed(function(use)
					return string.format(UIText.Owned, Format.number(use(owned)))
				end),
				Weight = "Regular",
				TextSize = 11,
				Color = Theme.Colors.TextMuted,
				Size = UDim2.fromOffset(80, 14),
				Position = UDim2.fromOffset(140, 34),
			}),
			if isBuy then button(2, UIText.BuyOne, "One") else button(2, UIText.SellOne, "One"),
			if isBuy
				then button(1, string.format(UIText.BuyBulk, ShopsConfig.BulkBuyAmount), "Bulk")
				else button(1, UIText.SellAll, "All"),
		},
	})
end

return function(scope: any, props: Props): Instance
	local rows = {}
	for _, entry in props.Shop.Items do
		table.insert(rows, row(scope, props, entry))
	end

	return Window(scope, {
		Name = ShopsConfig.screenName(props.Shop.Id),
		Title = string.upper(props.Shop.Title),
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(480, 380),
		Content = {
			ScrollList(scope, { Content = rows, Gap = 8 }),
		},
	})
end
