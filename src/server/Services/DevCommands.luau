--!strict
--[[
	Command chat untuk testing — HANYA aktif di Roblox Studio (RunService:IsStudio()).
	Di server live module ini tidak melakukan apa pun.

	!give <ItemId> <jumlah>   tambah item lewat InventoryService (kena aturan tas penuh)
	!coins <jumlah>           tambah koin
	!clearbag                 kosongkan semua item
	!baglevel <level>         set level tas langsung
	!devhelp                  tampilkan daftar command di Output
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Items = require(ReplicatedStorage.Shared.Config.Items)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Net = require(ReplicatedStorage.Shared.Net)
local Bag = require(ReplicatedStorage.Shared.Rules.Bag)
local DataService = require(script.Parent.DataService)
local InventoryService = require(script.Parent.InventoryService)
local WalletService = require(script.Parent.WalletService)

local DevCommands = {}

local PREFIX = "!"

local function reply(player: Player, message: string)
	print(`[Dev] {player.Name}: {message}`)
	Net.bridge(NetworkConfig.Bridges.Notify):Fire(player, { Text = message })
end

local commands: { [string]: (player: Player, args: { string }) -> () } = {}

commands.give = function(player, args)
	local itemId = args[1]
	local amount = tonumber(args[2]) or 1
	if itemId == nil or Items[itemId] == nil then
		local ids = {}
		for id in Items do
			table.insert(ids, id)
		end
		table.sort(ids)
		reply(player, `Item tidak dikenal. Pilihan: {table.concat(ids, ", ")}`)
		return
	end
	local ok = InventoryService.tryAdd(player, itemId, math.floor(amount))
	reply(
		player,
		if ok
			then `+{amount} {itemId} (tas {InventoryService.getUsed(player)}/{InventoryService.getCapacity(player)})`
			else `DITOLAK: tas tidak muat (sisa {InventoryService.getFreeSpace(player)})`
	)
end

commands.coins = function(player, args)
	local amount = tonumber(args[1]) or 1000
	WalletService.add(player, amount)
	reply(player, `Koin sekarang {WalletService.getCoins(player)}`)
end

commands.clearbag = function(player)
	local data = DataService.getData(player)
	if data then
		for id in data.Inventory do
			data.Inventory[id] = 0
		end
		reply(player, "Tas dikosongkan")
	end
end

commands.baglevel = function(player, args)
	local data = DataService.getData(player)
	local level = tonumber(args[1])
	if data and level then
		data.BagLevel = Bag.clampLevel(level)
		reply(player, `Level tas = {data.BagLevel} (kapasitas {Bag.capacity(data.BagLevel)})`)
	end
end

commands.devhelp = function(player)
	reply(player, "!give <ItemId> <jumlah>, !coins <jumlah>, !clearbag, !baglevel <level>")
end

local function onChatted(player: Player, message: string)
	if string.sub(message, 1, 1) ~= PREFIX then
		return
	end
	local parts = string.split(string.sub(message, 2), " ")
	local name = string.lower(table.remove(parts, 1) or "")
	local command = commands[name]
	if command then
		command(player, parts)
	end
end

function DevCommands.start()
	if not RunService:IsStudio() then
		return
	end
	local function hook(player: Player)
		player.Chatted:Connect(function(message)
			onChatted(player, message)
		end)
	end
	for _, player in Players:GetPlayers() do
		hook(player)
	end
	Players.PlayerAdded:Connect(hook)
	print("[Dev] Command testing aktif (Studio). Ketik !devhelp di chat.")
end

return DevCommands
