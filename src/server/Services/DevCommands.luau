--!strict
--[[
	Command chat untuk testing — HANYA aktif di Roblox Studio (RunService:IsStudio()).
	Di server live module ini tidak melakukan apa pun.

	!give <ItemKey> <jumlah>  tambah item lewat InventoryService (kena aturan tas penuh)
	                          contoh: !give Bamboo 10, !give Kite@Legendary 1, !give Naga@Mythic 1
	!coins <jumlah>           tambah koin
	!clearbag                 kosongkan semua item
	!baglevel <level>         set level tas langsung
	!exp <jumlah>             tambah EXP (bisa naik level)
	!tablelevel <level>       set level Meja Rakit
	!finishcraft              selesaikan crafting sekarang
	!golden                   munculkan Pohon Bambu Emas sekarang
	!pass <VIP|X2Exp|Luck2>   nyalakan/matikan efek gamepass (Studio saja)
	!devhelp                  tampilkan daftar command di Output
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Items = require(ReplicatedStorage.Shared.Config.Items)
local Gamepasses = require(ReplicatedStorage.Shared.Config.Gamepasses)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Net = require(ReplicatedStorage.Shared.Net)
local Bag = require(ReplicatedStorage.Shared.Rules.Bag)
local DataService = require(script.Parent.DataService)
local InventoryService = require(script.Parent.InventoryService)
local WalletService = require(script.Parent.WalletService)
local ProgressionService = require(script.Parent.ProgressionService)
local GamepassService = require(script.Parent.GamepassService)
local TableRules = require(ReplicatedStorage.Shared.Rules.CraftingTable)

local DevCommands = {}

local PREFIX = "!"

local function reply(player: Player, message: string)
	print(`[Dev] {player.Name}: {message}`)
	Net.bridge(NetworkConfig.Bridges.Notify):Fire(player, { Text = message })
end

local commands: { [string]: (player: Player, args: { string }) -> () } = {}

commands.give = function(player, args)
	local key = args[1]
	local amount = tonumber(args[2]) or 1
	if key and Items[key] and Items[key].HasRarity then
		key = ItemKey.make(key, "Common")
	end
	if key == nil or not ItemKey.isValid(key) then
		local ids = {}
		for id, def in Items do
			table.insert(ids, if def.HasRarity then id .. "@<Rarity>" else id)
		end
		table.sort(ids)
		reply(player, `Item tidak dikenal. Pilihan: {table.concat(ids, ", ")}`)
		return
	end
	local itemId = key
	local ok = InventoryService.tryAdd(player, key, math.floor(amount))
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
		for key in data.Inventory do
			data.Inventory[key] = if ItemKey.rarity(key) then nil else 0
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

commands.exp = function(player, args)
	ProgressionService.addExp(player, tonumber(args[1]) or 100)
	local data = DataService.getData(player)
	if data then
		reply(player, `Level {data.Level}, EXP {data.Exp}`)
	end
end

commands.tablelevel = function(player, args)
	local data = DataService.getData(player)
	local level = tonumber(args[1])
	if data and level then
		data.TableLevel = TableRules.clampLevel(level)
		reply(player, `Level meja = {data.TableLevel}`)
	end
end

commands.finishcraft = function(player)
	local data = DataService.getData(player)
	if data and data.ActiveCraft then
		data.ActiveCraft.EndsAt = workspace:GetServerTimeNow()
		reply(player, "Crafting diselesaikan")
	end
end

commands.golden = function(player)
	local system = script.Parent.Parent.Systems:FindFirstChild("goldenTrees")
	if system then
		(require(system) :: any).forceSpawn = true
		reply(player, "Pohon Bambu Emas akan muncul")
	end
end

commands.pass = function(player, args)
	local passKey = args[1]
	if passKey == nil or Gamepasses.Passes[passKey] == nil then
		reply(player, "Pilihan: VIP, X2Exp, Luck2")
		return
	end
	local enabled = not GamepassService.owns(player, passKey)
	GamepassService.setDevOverride(player, passKey, enabled)
	reply(
		player,
		`{passKey} {if enabled then "ON" else "OFF"} (EXP x{GamepassService.expMultiplier(player)}, Luck x{GamepassService.luckMultiplier(player)})`
	)
end

commands.devhelp = function(player)
	reply(
		player,
		"!give <Item> <n>, !coins, !exp, !clearbag, !baglevel, !tablelevel, !finishcraft, !golden, !pass <VIP|X2Exp|Luck2>"
	)
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
