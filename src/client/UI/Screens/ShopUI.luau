--!strict
--[[
	Shop (tombol Shop di sidebar): kartu gamepass seperti referensi Shop
	(gambar besar kiri, nama, deskripsi, tombol harga Robux). Tone gelap metalik.
	Pembelian: MarketplaceService:PromptGamePassPurchase (dipanggil controller).
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)
local Gamepasses = require(ReplicatedStorage.Shared.Config.Gamepasses)
local Format = require(ReplicatedStorage.Shared.Util.Format)

local Components = script.Parent.Parent.Components
local Window = require(Components.Window)
local Panel = require(Components.Panel)
local Text = require(Components.Text)
local Icon = require(Components.Icon)
local Button = require(Components.Button)
local ScrollList = require(Components.ScrollList)

export type Props = {
	Open: any,
	OnClose: () -> (),
	Owned: any, -- { [passKey]: boolean } (state)
	Prices: any, -- { [passKey]: number? } harga Robux (state)
	OnBuy: (passKey: string) -> (),
	Scale: any?,
}

local CARD_HEIGHT = 96

return function(scope: any, props: Props): Instance
	local keys = {}
	for key in Gamepasses.Passes do
		table.insert(keys, key)
	end
	table.sort(keys, function(a, b)
		return Gamepasses.Passes[a].Order < Gamepasses.Passes[b].Order
	end)

	local cards = {}
	for index, key in keys do
		local pass = Gamepasses.Passes[key]
		local owned = scope:Computed(function(use)
			return use(props.Owned)[key] == true
		end)
		table.insert(
			cards,
			Panel(scope, {
				Name = key,
				LayoutOrder = index,
				Size = UDim2.new(1, 0, 0, CARD_HEIGHT),
				Color = Theme.Colors.PanelSoft,
				StrokeTransparency = Theme.Transparency.ButtonStroke,
				Content = {
					Panel(scope, {
						Name = "Artwork",
						Size = UDim2.fromOffset(CARD_HEIGHT - 16, CARD_HEIGHT - 16),
						Position = UDim2.fromOffset(8, 8),
						Color = Theme.Colors.Slot,
						Corner = Theme.Sizes.Corner,
						Content = {
							Icon(scope, {
								Asset = UIAssets.Gamepasses[key],
								Size = UDim2.fromScale(0.9, 0.9),
								Position = UDim2.fromScale(0.5, 0.5),
								AnchorPoint = Vector2.new(0.5, 0.5),
							}),
						},
					}),
					Text(scope, {
						Name = "NameText",
						Text = pass.DisplayName,
						Weight = "Black",
						TextSize = 16,
						Metallic = true,
						Size = UDim2.new(1, -(CARD_HEIGHT + 8), 0, 22),
						Position = UDim2.fromOffset(CARD_HEIGHT, 10),
					}),
					Text(scope, {
						Name = "DescriptionText",
						Text = pass.Description,
						Weight = "Regular",
						TextSize = 12,
						Color = Theme.Colors.TextDim,
						Wrapped = true,
						YAlignment = Enum.TextYAlignment.Top,
						Size = UDim2.new(1, -(CARD_HEIGHT + 8), 0, 30),
						Position = UDim2.fromOffset(CARD_HEIGHT, 34),
					}),
					Button(scope, {
						Name = "BuyButton",
						Size = UDim2.fromOffset(96, 28),
						AnchorPoint = Vector2.new(1, 1),
						Position = UDim2.new(1, -8, 1, -8),
						TextSize = 12,
						Text = scope:Computed(function(use)
							if use(owned) then
								return UIText.ShopOwned
							end
							local price = use(props.Prices)[key]
							return if price then string.format(UIText.ShopRobux, Format.number(price)) else UIText.ShopUnavailable
						end),
						Variant = scope:Computed(function(use)
							return if use(owned) then "Ghost" else "Metal"
						end),
						Disabled = scope:Computed(function(use)
							return use(owned) or pass.Id == 0
						end),
						OnActivated = function()
							props.OnBuy(key)
						end,
					}),
				},
			})
		)
	end

	return Window(scope, {
		Name = "Shop",
		Title = UIText.ShopTitle,
		Open = props.Open,
		OnClose = props.OnClose,
		Scale = props.Scale,
		Size = UDim2.fromOffset(340, 420),
		Content = {
			ScrollList(scope, { Content = cards, Gap = 10 }),
		},
	})
end
