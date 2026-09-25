--!strict
-- Upgrade Meja Rakit: harus pemilik, dekat papan nama/meja sendiri, koin cukup.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlotConfig = require(ReplicatedStorage.Shared.Config.Plot)
local TableConfig = require(ReplicatedStorage.Shared.Config.CraftingTable)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local TableRules = require(ReplicatedStorage.Shared.Rules.CraftingTable)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local WalletService = require(Server.Services.WalletService)
local IntentQueue = require(Server.Util.IntentQueue)
local RateLimiter = require(Server.Util.RateLimiter)
local Validation = require(Server.Util.Validation)
local Queries = require(Server.Util.Queries)
local notify = require(Server.Util.Notify)

local BRIDGE = NetworkConfig.Bridges.RequestTableUpgrade
IntentQueue.listen(BRIDGE)
local limiter = RateLimiter.new(NetworkConfig.RateLimits.TableUpgrade)

local function handle(world, player: Player)
	if player.Parent ~= Players or not limiter:check(player) then
		return
	end
	local data = DataService.getData(player)
	if data == nil then
		return
	end
	local plotId, plot, craftingTable = Queries.tableOf(world, player)
	if plotId == nil then
		notify(player, Messages.NoTable)
		return
	end

	local nearSign = Validation.isWithinDistance(
		player,
		plot.sign:GetPivot().Position,
		PlotConfig.MaxActivationDistance + PlotConfig.DistanceTolerance
	)
	local nearTable = Validation.isWithinDistance(
		player,
		craftingTable.model:GetPivot().Position,
		TableConfig.InteractDistance + TableConfig.DistanceTolerance
	)
	if not (nearSign or nearTable) then
		notify(player, Messages.TooFar)
		return
	end

	local cost = TableRules.upgradeCost(data.TableLevel)
	if cost == nil then
		notify(player, Messages.TableMaxLevel)
		return
	end
	if not WalletService.trySpend(player, cost) then
		notify(player, Messages.NotEnoughCoins)
		return
	end
	data.TableLevel = TableRules.clampLevel(data.TableLevel + 1)
	notify(player, string.format(Messages.TableUpgraded, data.TableLevel))
end

local function tableUpgrades(world)
	for _, intent in IntentQueue.drain(BRIDGE) do
		handle(world, intent.player)
	end
end

return { system = tableUpgrades, priority = 50 }
