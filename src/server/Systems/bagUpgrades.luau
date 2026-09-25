--!strict
-- Proses intent naik level tas: validasi level & koin di server, lalu naikkan BagLevel.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local Bag = require(ReplicatedStorage.Shared.Rules.Bag)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local WalletService = require(Server.Services.WalletService)
local RateLimiter = require(Server.Util.RateLimiter)
local IntentQueue = require(Server.Util.IntentQueue)

local BRIDGE = NetworkConfig.Bridges.RequestBagUpgrade
IntentQueue.listen(BRIDGE)

local limiter = RateLimiter.new(NetworkConfig.RateLimits.BagUpgrade)
local notifyBridge = Net.bridge(NetworkConfig.Bridges.Notify)

local function notify(player: Player, text: string)
	notifyBridge:Fire(player, { Text = text })
end

local function handle(player: Player)
	if player.Parent ~= Players or not limiter:check(player) then
		return
	end
	local data = DataService.getData(player)
	if data == nil then
		notify(player, Messages.DataNotLoaded)
		return
	end

	local price = Bag.upgradePrice(data.BagLevel)
	if price == nil then
		notify(player, Messages.BagMaxLevel)
		return
	end
	if not WalletService.trySpend(player, price) then
		notify(player, Messages.NotEnoughCoins)
		return
	end

	data.BagLevel = Bag.clampLevel(data.BagLevel + 1)
	notify(player, string.format(Messages.BagUpgraded, data.BagLevel))
end

local function bagUpgrades(_world)
	for _, intent in IntentQueue.drain(BRIDGE) do
		handle(intent.player)
	end
end

return { system = bagUpgrades, priority = 50 }
