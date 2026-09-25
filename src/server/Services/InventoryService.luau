--!strict
--[[
	InventoryService: SATU-SATUNYA jalan untuk menambah/mengurangi item di server.
	Semua fungsi memakai item key (Rules/ItemKey): "Bamboo", "Kite@Legendary", ...
	Item dengan CountsToBag menghitung ke kapasitas tas (Rules/Bag).
	Loot yang tidak muat ditolak dan pemain dapat notifikasi "Tas Penuh!".
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Bags = require(ReplicatedStorage.Shared.Config.Bags)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local Bag = require(ReplicatedStorage.Shared.Rules.Bag)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)
local DataService = require(ServerScriptService.Server.Services.DataService)
local notify = require(ServerScriptService.Server.Util.Notify)

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
	notify(player, Messages.BagFull)
end

function InventoryService.getCount(player: Player, key: string): number
	local data = DataService.getData(player)
	return if data then data.Inventory[key] or 0 else 0
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

-- Cek apakah beberapa item sekaligus muat di tas: { [key] = jumlah }
function InventoryService.canAddMany(player: Player, items: { [string]: number }): boolean
	if DataService.getData(player) == nil then
		return false
	end
	local needed = 0
	for key, amount in items do
		local def = ItemKey.def(key)
		if not ItemKey.isValid(key) or def == nil or not isValidAmount(amount) then
			return false
		end
		if def.CountsToBag then
			needed += amount
		end
	end
	return InventoryService.getFreeSpace(player) >= needed
end

function InventoryService.canAdd(player: Player, key: string, amount: number): boolean
	return InventoryService.canAddMany(player, { [key] = amount })
end

--[[
	Tambah item. Ditolak seluruhnya kalau tidak muat (tidak ada tambah sebagian).
	options.silent = true -> tidak kirim notifikasi "Tas Penuh!"
]]
function InventoryService.tryAdd(player: Player, key: string, amount: number, options: { silent: boolean? }?): boolean
	local data = DataService.getData(player)
	if data == nil or not ItemKey.isValid(key) or not isValidAmount(amount) then
		return false
	end
	if not InventoryService.canAdd(player, key, amount) then
		if not (options and options.silent) then
			InventoryService.notifyBagFull(player)
		end
		return false
	end
	data.Inventory[key] = (data.Inventory[key] or 0) + amount
	return true
end

function InventoryService.tryRemove(player: Player, key: string, amount: number): boolean
	local data = DataService.getData(player)
	if data == nil or not ItemKey.isValid(key) or not isValidAmount(amount) then
		return false
	end
	local current = data.Inventory[key] or 0
	if current < amount then
		return false
	end
	local remaining = current - amount
	-- Item ber-rarity yang habis dihapus dari tabel supaya data tetap kecil
	if remaining == 0 and ItemKey.rarity(key) ~= nil then
		data.Inventory[key] = nil
	else
		data.Inventory[key] = remaining
	end
	-- Item habis -> lepas dari hotbar
	if remaining == 0 and data.Hotbar then
		local index = table.find(data.Hotbar, key)
		if index then
			table.remove(data.Hotbar, index)
		end
	end
	return true
end

-- Kurangi beberapa item sekaligus (mis. bahan crafting). Semua atau tidak sama sekali.
function InventoryService.tryRemoveMany(player: Player, cost: { [string]: number }): boolean
	for key, amount in cost do
		if not isValidAmount(amount) or InventoryService.getCount(player, key) < amount then
			return false
		end
	end
	for key, amount in cost do
		InventoryService.tryRemove(player, key, amount)
	end
	return true
end

Players.PlayerRemoving:Connect(function(player)
	lastFullNotify[player] = nil
end)

return InventoryService
