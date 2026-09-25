--!strict
--[[
	Mulai merakit. Client hanya kirim { RecipeId, UseBooster }.
	Validasi server: resep ada, punya meja sendiri & berada di dekatnya, meja tidak sibuk,
	level meja cukup, bahan (+ booster) cukup — semua dikurangi saat mulai.
	Aura Naga di kavling memotong waktu merakit.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Recipes = require(ReplicatedStorage.Shared.Config.Recipes)
local TableConfig = require(ReplicatedStorage.Shared.Config.CraftingTable)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local TableRules = require(ReplicatedStorage.Shared.Rules.CraftingTable)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)

local Server = script.Parent.Parent
local DataService = require(Server.Services.DataService)
local InventoryService = require(Server.Services.InventoryService)
local IntentQueue = require(Server.Util.IntentQueue)
local RateLimiter = require(Server.Util.RateLimiter)
local Validation = require(Server.Util.Validation)
local Queries = require(Server.Util.Queries)
local notify = require(Server.Util.Notify)

local BRIDGE = NetworkConfig.Bridges.RequestCraft
IntentQueue.listen(BRIDGE)
local limiter = RateLimiter.new(NetworkConfig.RateLimits.Craft)

local function handle(world, player: Player, payload: any)
	if player.Parent ~= Players or not limiter:check(player) then
		return
	end
	local data = DataService.getData(player)
	if data == nil or type(payload) ~= "table" or type(payload.RecipeId) ~= "string" then
		return
	end
	local recipe = Recipes[payload.RecipeId]
	if recipe == nil then
		return
	end

	local plotId, _, craftingTable = Queries.tableOf(world, player)
	if plotId == nil then
		notify(player, Messages.NoTable)
		return
	end
	local maxDistance = TableConfig.InteractDistance + TableConfig.DistanceTolerance
	if not Validation.isWithinDistance(player, craftingTable.model:GetPivot().Position, maxDistance) then
		notify(player, Messages.TooFar)
		return
	end
	if data.ActiveCraft ~= nil then
		notify(player, Messages.TableBusy)
		return
	end
	local requiredLevel = TableRules.requiredLevel(recipe.Id)
	if data.TableLevel < requiredLevel then
		notify(player, string.format(Messages.TableLevelTooLow, requiredLevel))
		return
	end

	local useBooster = payload.UseBooster == true and recipe.Booster ~= nil
	if useBooster and not TableRules.hasMaterials(data.Inventory, recipe.Id, true) then
		if TableRules.hasMaterials(data.Inventory, recipe.Id, false) then
			notify(player, Messages.NoBooster)
		else
			notify(player, Messages.MissingMaterials)
		end
		return
	end
	if not InventoryService.tryRemoveMany(player, TableRules.cost(recipe.Id, useBooster)) then
		notify(player, Messages.MissingMaterials)
		return
	end

	local dragonActive = data.PlacedDragon ~= nil
	data.ActiveCraft = {
		RecipeId = recipe.Id,
		EndsAt = workspace:GetServerTimeNow() + TableRules.craftDuration(recipe.Id, data.TableLevel, dragonActive),
		Boosted = useBooster,
	}
	notify(player, string.format(Messages.CraftStarted, ItemKey.displayName(recipe.Output)))
end

local function crafting(world)
	for _, intent in IntentQueue.drain(BRIDGE) do
		handle(world, intent.player, intent.payload)
	end
end

return { system = crafting, priority = 50 }
