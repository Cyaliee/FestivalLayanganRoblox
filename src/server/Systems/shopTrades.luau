--!strict
--[[
	Transaksi pasar. Client hanya kirim { ShopId, ItemId, Mode }.
	Harga dari Config/Shops, jumlah dihitung server dari Mode:
	  Beli: One = 1, Bulk = BulkBuyAmount (dibatasi koin & sisa tas)
	  Jual: One = 1, All = semua yang dimiliki
	Jarak ke NPC toko itu divalidasi di server.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.Components)
local Items = require(ReplicatedStorage.Shared.Config.Items)
local ShopsConfig = require(ReplicatedStorage.Shared.Config.Shops)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local Format = require(ReplicatedStorage.Shared.Util.Format)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local InventoryService = require(Server.Services.InventoryService)
local WalletService = require(Server.Services.WalletService)
local IntentQueue = require(Server.Util.IntentQueue)
local RateLimiter = require(Server.Util.RateLimiter)
local Validation = require(Server.Util.Validation)
local notify = require(Server.Util.Notify)

local BRIDGE = NetworkConfig.Bridges.RequestTrade
IntentQueue.listen(BRIDGE)
local limiter = RateLimiter.new(NetworkConfig.RateLimits.Trade)

local function isNearShop(world, player: Player, shopId: string): boolean
	local maxDistance = ShopsConfig.InteractDistance + ShopsConfig.DistanceTolerance
	for _, npc in world:query(Components.ShopNpc) do
		if npc.shopId == shopId and Validation.isWithinDistance(player, npc.position, maxDistance) then
			return true
		end
	end
	return false
end

local function buy(player: Player, itemId: string, price: number, mode: string)
	local wanted = if mode == "Bulk" then ShopsConfig.BulkBuyAmount else 1
	local affordable = math.floor(WalletService.getCoins(player) / price)
	local space = if Items[itemId].CountsToBag then InventoryService.getFreeSpace(player) else wanted
	local amount = math.min(wanted, affordable, space)

	if affordable <= 0 then
		notify(player, Messages.NotEnoughCoins)
		return
	end
	if amount <= 0 then
		InventoryService.notifyBagFull(player)
		return
	end
	if WalletService.trySpend(player, amount * price) then
		if InventoryService.tryAdd(player, itemId, amount) then
			notify(player, string.format(Messages.Bought, amount, Items[itemId].DisplayName))
		else
			WalletService.add(player, amount * price) -- kembalikan (seharusnya tidak terjadi)
		end
	end
end

local function sell(player: Player, itemId: string, price: number, mode: string)
	local owned = InventoryService.getCount(player, itemId)
	local amount = if mode == "All" then owned else 1
	if owned <= 0 or amount <= 0 then
		notify(player, Messages.NotEnoughItems)
		return
	end
	if InventoryService.tryRemove(player, itemId, amount) then
		local earned = amount * price
		WalletService.add(player, earned)
		notify(player, string.format(Messages.Sold, amount, Items[itemId].DisplayName, Format.number(earned)))
	end
end

local function handle(world, player: Player, payload: any)
	if player.Parent ~= Players or DataService.getData(player) == nil or not limiter:check(player) then
		return
	end
	if type(payload) ~= "table" then
		return
	end
	local shopId, itemId, mode = payload.ShopId, payload.ItemId, payload.Mode
	if type(shopId) ~= "string" or type(itemId) ~= "string" or type(mode) ~= "string" then
		return
	end
	local shop = ShopsConfig.Shops[shopId]
	local entry = shop and ShopsConfig.findItem(shop, itemId)
	if shop == nil or entry == nil or not ShopsConfig.Modes[mode] then
		return
	end
	if not isNearShop(world, player, shopId) then
		notify(player, Messages.TooFar)
		return
	end

	if shop.Type == "Buy" and mode ~= "All" then
		buy(player, itemId, entry.Price, mode)
	elseif shop.Type == "Sell" and mode ~= "Bulk" then
		sell(player, itemId, entry.Price, mode)
	end
end

local function shopTrades(world)
	for _, intent in IntentQueue.drain(BRIDGE) do
		handle(world, intent.player, intent.payload)
	end
end

return { system = shopTrades, priority = 50 }
