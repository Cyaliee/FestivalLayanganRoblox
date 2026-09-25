--!strict
--[[
	Mulai merakit. Client hanya kirim { RecipeId }.
	Validasi server: resep ada, punya meja sendiri & berada di dekatnya, meja tidak sibuk,
	level meja cukup, bahan cukup (dikurangi saat mulai).
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Recipes = require(ReplicatedStorage.Shared.Config.Recipes)
local Items = require(ReplicatedStorage.Shared.Config.Items)
local TableConfig = require(ReplicatedStorage.Shared.Config.CraftingTable)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local Messages = require(ReplicatedStorage.Shared.Config.Messages)
local TableRules = require(ReplicatedStorage.Shared.Rules.CraftingTable)

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
	if data.TableLevel < recipe.RequiredTableLevel then
		notify(player, string.format(Messages.TableLevelTooLow, recipe.RequiredTableLevel))
		return
	end
	if not InventoryService.tryRemoveMany(player, recipe.Inputs) then
		notify(player, Messages.MissingMaterials)
		return
	end

	data.ActiveCraft = {
		RecipeId = recipe.Id,
		EndsAt = workspace:GetServerTimeNow() + TableRules.craftDuration(recipe.Id, data.TableLevel),
	}
	notify(player, string.format(Messages.CraftStarted, Items[recipe.Output].DisplayName))
end

local function crafting(world)
	for _, intent in IntentQueue.drain(BRIDGE) do
		handle(world, intent.player, intent.payload)
	end
end

return { system = crafting, priority = 50 }
