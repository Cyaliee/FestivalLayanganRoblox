--!strict
-- Spawn MejaRakit di kavling yang punya Owner, hapus saat Owner dilepas,
-- tambahkan prompt "Rakit Layangan", dan sinkronkan level & crafting aktif dari data pemain.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Components = require(ReplicatedStorage.Shared.Components)
local PlotConfig = require(ReplicatedStorage.Shared.Config.Plot)
local TableConfig = require(ReplicatedStorage.Shared.Config.CraftingTable)
local DataService = require(script.Parent.Parent.Services.DataService)
local warnOnce = require(script.Parent.Parent.Util.WarnOnce)

local Plot = Components.Plot
local Owner = Components.Owner
local CraftingTable = Components.CraftingTable

local function getTableAsset(): Model?
	local folder = ServerStorage:FindFirstChild(PlotConfig.AssetFolder)
	local asset = folder and folder:FindFirstChild(PlotConfig.TableAssetName)
	if asset == nil or not asset:IsA("Model") then
		warnOnce(
			"tableasset",
			`[CraftingTable] Model ServerStorage/{PlotConfig.AssetFolder}/{PlotConfig.TableAssetName} tidak ada`
		)
		return nil
	end
	return asset
end

local function clampLevel(level: number): number
	return math.clamp(level, 1, TableConfig.MaxLevel)
end

local function addPrompt(model: Model): ProximityPrompt?
	local parent = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if parent == nil then
		warn(`[CraftingTable] {model:GetFullName()} tidak punya BasePart untuk ProximityPrompt`)
		return nil
	end
	local prompt = model:FindFirstChild(TableConfig.PromptName, true)
	if prompt == nil or not prompt:IsA("ProximityPrompt") then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = TableConfig.PromptName
		prompt.Parent = parent
	end
	local p = prompt :: ProximityPrompt
	p.ActionText = TableConfig.PromptActionText
	p.ObjectText = TableConfig.PromptObjectText
	p.HoldDuration = TableConfig.PromptHoldDuration
	p.MaxActivationDistance = TableConfig.InteractDistance
	p.RequiresLineOfSight = false
	return p
end

local function craftingTables(world)
	-- Spawn meja untuk kavling yang baru diklaim
	for id, plot, owner in world:query(Plot, Owner):without(CraftingTable) do
		local data = DataService.getData(owner.player)
		local asset = getTableAsset()
		if data == nil or asset == nil then
			continue
		end

		local level = clampLevel(data.TableLevel)
		local model = asset:Clone()
		model.Name = PlotConfig.SpawnedTableName
		model:PivotTo(plot.tableSpawn)
		model:SetAttribute(TableConfig.OwnerAttribute, owner.userId)
		model:SetAttribute(TableConfig.LevelAttribute, level)
		model.Parent = plot.model

		world:insert(id, CraftingTable({ Level = level, model = model, prompt = addPrompt(model) }))
	end

	-- Hapus meja dari kavling yang sudah dilepas
	local orphaned = {}
	for id, craftingTable in world:query(CraftingTable):without(Owner) do
		table.insert(orphaned, id)
		craftingTable.model:Destroy()
	end
	for _, id in orphaned do
		world:remove(id, CraftingTable)
	end

	-- Sinkron level & crafting aktif dari data pemain (client membaca attribute untuk billboard)
	for id, craftingTable, owner in world:query(CraftingTable, Owner) do
		local data = DataService.getData(owner.player)
		if data == nil then
			continue
		end
		local level = clampLevel(data.TableLevel)
		if level ~= craftingTable.Level then
			craftingTable.model:SetAttribute(TableConfig.LevelAttribute, level)
			world:insert(id, craftingTable:patch({ Level = level }))
		end

		local model = craftingTable.model
		local craft = data.ActiveCraft
		local recipeId = if craft then craft.RecipeId else nil
		local endsAt = if craft then craft.EndsAt else nil
		if model:GetAttribute(TableConfig.CraftRecipeAttribute) ~= recipeId then
			model:SetAttribute(TableConfig.CraftRecipeAttribute, recipeId)
		end
		if model:GetAttribute(TableConfig.CraftEndsAtAttribute) ~= endsAt then
			model:SetAttribute(TableConfig.CraftEndsAtAttribute, endsAt)
		end
	end
end

return { system = craftingTables, priority = 30 }
