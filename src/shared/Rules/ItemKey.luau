--!strict
-- Key inventory: "Bamboo" untuk item biasa, "Kite@Legendary" untuk item ber-rarity.
local Items = require(script.Parent.Parent.Config.Items)
local Rarity = require(script.Parent.Parent.Config.Rarity)

local ItemKey = {}

local SEPARATOR = "@"

function ItemKey.make(itemId: string, rarity: string?): string
	local def = Items[itemId]
	if def and def.HasRarity then
		return itemId .. SEPARATOR .. (rarity or "Common")
	end
	return itemId
end

-- return itemId, rarity (rarity nil untuk item tanpa rarity)
function ItemKey.parse(key: string): (string, string?)
	local at = string.find(key, SEPARATOR, 1, true)
	if at == nil then
		return key, nil
	end
	return string.sub(key, 1, at - 1), string.sub(key, at + 1)
end

function ItemKey.def(key: string): Items.ItemDef?
	local itemId = ItemKey.parse(key)
	return Items[itemId]
end

-- Key valid: item ada, dan rarity ada kalau item ber-rarity (atau tidak ada kalau tidak)
function ItemKey.isValid(key: any): boolean
	if type(key) ~= "string" then
		return false
	end
	local itemId, rarity = ItemKey.parse(key)
	local def = Items[itemId]
	if def == nil then
		return false
	end
	if def.HasRarity then
		return rarity ~= nil and Rarity.Tiers[rarity] ~= nil
	end
	return rarity == nil
end

function ItemKey.rarity(key: string): Rarity.Tier?
	local _, rarity = ItemKey.parse(key)
	return if rarity then Rarity.Tiers[rarity] else nil
end

-- "Layangan (Legendary)" / "Bambu"
function ItemKey.displayName(key: string): string
	local itemId, rarity = ItemKey.parse(key)
	local def = Items[itemId]
	local name = if def then def.DisplayName else itemId
	local tier = if rarity then Rarity.Tiers[rarity] else nil
	if tier then
		return `{name} ({tier.DisplayName})`
	end
	return name
end

-- Pengali reward/harga dari rarity (1 untuk item tanpa rarity)
function ItemKey.multiplier(key: string): number
	local tier = ItemKey.rarity(key)
	return if tier then tier.Multiplier else 1
end

-- Urutan tampil: Order item, lalu Rank rarity
function ItemKey.sortValue(key: string): number
	local def = ItemKey.def(key)
	local tier = ItemKey.rarity(key)
	return (if def then def.Order else 999) * 10 + (if tier then tier.Rank else 0)
end

return ItemKey
