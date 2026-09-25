--!strict
--[[
	InventoryService: SATU-SATUNYA jalan untuk menambah/mengurangi item di server.
	Semua item dengan CountsToBag menghitung ke kapasitas tas (Rules/Bag).
	Loot yang tidak muat ditolak dan pemain dapat notifikasi "Tas Penuh!".
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Items = require(ReplicatedStorage.Shared.Config.Items)
local Bags = require(ReplicatedStorage.Shared.Config.Bags)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Bag = require(ReplicatedStorage.Shared.Rules.Bag)
local Net = require(ReplicatedStorage.Shared.Net)
local DataService = require(ServerScriptService.Server.Services.DataService)

local InventoryService = {}

local lastFullNotify: { [Player]: number } = {}

local function isValidAmount(amount: number): boolean
	return type(amount) == "number" and amount > 0 and amount == math.floor(amount)
end

function InventoryService.notifyBagFull(player: Player)
	local now = os.clock()
	local last = lastFullNotify[player]
	if last and now - last < Bags.FullNotifyCooldown then
		return
	end
	lastFullNotify[player] = now
	Net.bridge(NetworkConfig.Bridges.Notify):Fire(player, { Text = Messages.BagFull })
end

function InventoryService.getCount(player: Player, itemId: string): number
	local data = DataService.getData(player)
	return if data then data.Inventory[itemId] or 0 else 0
end

function InventoryService.getUsed(player: Player): number
	local data = DataService.getData(player)
	return if data then Bag.used(data.Inventory) else 0
end

function InventoryService.getCapacity(player: Player): number
	local data = DataService.getData(player)
	return Bag.capacity(if data then data.BagLevel else 1)
end

function InventoryService.getFreeSpace(player: Player): number
	return math.max(0, InventoryService.getCapacity(player) - InventoryService.getUsed(player))
end

-- Cek apakah `amount` item muat di tas (tanpa mengubah apa pun)
function InventoryService.canAdd(player: Player, itemId: string, amount: number): boolean
	local def = Items[itemId]
	if def == nil or not isValidAmount(amount) or DataService.getData(player) == nil then
		return false
	end
	return not def.CountsToBag or InventoryService.getFreeSpace(player) >= amount
end

--[[
	Tambah item. Ditolak seluruhnya kalau tidak muat (tidak ada tambah sebagian).
	options.silent = true -> tidak kirim notifikasi "Tas Penuh!"
	return true kalau item masuk.
]]
function InventoryService.tryAdd(player: Player, itemId: string, amount: number, options: { silent: boolean? }?): boolean
	local data = DataService.getData(player)
	if data == nil or Items[itemId] == nil or not isValidAmount(amount) then
		return false
	end
	if not InventoryService.canAdd(player, itemId, amount) then
		if not (options and options.silent) then
			InventoryService.notifyBagFull(player)
		end
		return false
	end
	data.Inventory[itemId] = (data.Inventory[itemId] or 0) + amount
	return true
end

-- Kurangi item kalau jumlahnya cukup. true = berhasil.
function InventoryService.tryRemove(player: Player, itemId: string, amount: number): boolean
	local data = DataService.getData(player)
	if data == nil or Items[itemId] == nil or not isValidAmount(amount) then
		return false
	end
	local current = data.Inventory[itemId] or 0
	if current < amount then
		return false
	end
	data.Inventory[itemId] = current - amount
	return true
end

-- Kurangi beberapa item sekaligus (mis. bahan crafting). Semua atau tidak sama sekali.
function InventoryService.tryRemoveMany(player: Player, cost: { [string]: number }): boolean
	for itemId, amount in cost do
		if InventoryService.getCount(player, itemId) < amount or not isValidAmount(amount) then
			return false
		end
	end
	for itemId, amount in cost do
		InventoryService.tryRemove(player, itemId, amount)
	end
	return true
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	lastFullNotify[player] = nil
end)

return InventoryService
