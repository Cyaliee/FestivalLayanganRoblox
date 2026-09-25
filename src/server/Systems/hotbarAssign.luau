--!strict
-- Klik item di Inventory: pasang ke slot hotbar kosong pertama, atau lepas kalau sudah terpasang.
-- Client hanya kirim { Key }; server cek kepemilikan, kategori, dan jumlah slot.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HotbarConfig = require(ReplicatedStorage.Shared.Config.Hotbar)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local IntentQueue = require(Server.Util.IntentQueue)
local RateLimiter = require(Server.Util.RateLimiter)
local notify = require(Server.Util.Notify)

local BRIDGE = NetworkConfig.Bridges.RequestHotbarToggle
IntentQueue.listen(BRIDGE)
local limiter = RateLimiter.new(NetworkConfig.RateLimits.HotbarToggle)

local ASSIGNABLE_SLOTS = HotbarConfig.SlotCount - #HotbarConfig.Tools

local function handle(player: Player, payload: any)
	if player.Parent ~= Players or not limiter:check(player) then
		return
	end
	local data = DataService.getData(player)
	local key = if type(payload) == "table" then payload.Key else nil
	if data == nil or not ItemKey.isValid(key) then
		return
	end

	for index, existing in data.Hotbar do
		if existing == key then
			table.remove(data.Hotbar, index)
			return
		end
	end

	local def = ItemKey.def(key) :: any
	if not HotbarConfig.AssignableCategories[def.Category] then
		if def.Category == "Dragon" then
			notify(player, Messages.DragonNotHotbar)
		end
		return
	end
	if (data.Inventory[key] or 0) <= 0 then
		return
	end
	if #data.Hotbar >= ASSIGNABLE_SLOTS then
		notify(player, Messages.HotbarFull)
		return
	end
	table.insert(data.Hotbar, key)
end

local function hotbarAssign(_world)
	for _, intent in IntentQueue.drain(BRIDGE) do
		handle(intent.player, intent.payload)
	end
end

return { system = hotbarAssign, priority = 50 }
