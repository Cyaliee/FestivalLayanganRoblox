--!strict
--[[
	Pilihan slot hotbar dari client: { Id: string? }  (Id = item key, mis. "Kite@Epic")
	  "Axe"           -> pegang kapak
	  layangan (Kite) -> terbangkan (harus di Area Festival; 1 layangan habis)
	  lainnya / nil   -> lepas tool
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.Components)
local Kites = require(ReplicatedStorage.Shared.Config.Kites)
local Farming = require(ReplicatedStorage.Shared.Config.Farming)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local InventoryService = require(Server.Services.InventoryService)
local ToolService = require(Server.Services.ToolService)
local KiteService = require(Server.Services.KiteService)
local IntentQueue = require(Server.Util.IntentQueue)
local RateLimiter = require(Server.Util.RateLimiter)
local FestivalArea = require(Server.Util.FestivalArea)
local Queries = require(Server.Util.Queries)
local notify = require(Server.Util.Notify)

local BRIDGE = NetworkConfig.Bridges.RequestEquip
IntentQueue.listen(BRIDGE)
local limiter = RateLimiter.new(NetworkConfig.RateLimits.Equip)

local function launchKite(world, player: Player, key: string)
	local kiteId = ItemKey.parse(key)
	local entityId = Queries.playerEntityId(world, player)
	if entityId == nil then
		return
	end
	if world:get(entityId, Components.Flying) then
		notify(player, Messages.AlreadyFlying)
		return
	end
	if not FestivalArea.containsPlayer(player) then
		notify(player, Messages.NotInFestival)
		return
	end
	if not InventoryService.tryRemove(player, key, 1) then
		notify(player, Messages.NoKite)
		return
	end

	local stats = Kites.Stats[kiteId]
	local now = workspace:GetServerTimeNow()
	local visual, anchor = KiteService.createVisual(player, key)
	world:insert(
		entityId,
		Components.Flying({
			kiteKey = key,
			kiteId = kiteId,
			endsAt = now + stats.Duration,
			nextTickAt = now + stats.TickInterval,
			model = visual,
			anchor = anchor,
		})
	)
	player:SetAttribute(Kites.KiteAttribute, key)
	player:SetAttribute(Kites.EndsAtAttribute, now + stats.Duration)
	player:SetAttribute(Kites.DurationAttribute, stats.Duration)
	notify(player, string.format(Messages.KiteLaunched, ItemKey.displayName(key)))
end

local function handle(world, player: Player, payload: any)
	if player.Parent ~= Players or DataService.getData(player) == nil or not limiter:check(player) then
		return
	end
	local id = if type(payload) == "table" then payload.Id else nil
	if id ~= nil and type(id) ~= "string" then
		return
	end

	if id == Farming.Axe.HotbarId then
		ToolService.equipAxe(player)
	elseif id and ItemKey.isValid(id) and (ItemKey.def(id) :: any).Category == "Kite" and Kites.Stats[ItemKey.parse(id)] then
		ToolService.unequip(player)
		launchKite(world, player, id)
	else
		ToolService.unequip(player)
	end
end

local function equipment(world)
	for _, intent in IntentQueue.drain(BRIDGE) do
		handle(world, intent.player, intent.payload)
	end
end

return { system = equipment, priority = 45 }
