--!strict
-- Billboard countdown di atas setiap MejaRakit yang sedang merakit ("5s", "4s", ... "Selesai!").
-- Dibuat dengan Fusion di client; data dari attribute meja (diisi server).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PlotConfig = require(ReplicatedStorage.Shared.Config.Plot)
local TableConfig = require(ReplicatedStorage.Shared.Config.CraftingTable)
local Recipes = require(ReplicatedStorage.Shared.Config.Recipes)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local UIAssets = require(ReplicatedStorage.Shared.Config.UIAssets)

local UI = script.Parent.Parent.UI
local Panel = require(UI.Components.Panel)
local Text = require(UI.Components.Text)
local Theme = require(ReplicatedStorage.Shared.Config.UITheme)
local Icon = require(UI.Components.Icon)

local peek = Fusion.peek
local Children = Fusion.Children

type Board = { scope: any, text: any, icon: any, visible: any }
local boards: { [Model]: Board } = {}

local function createBoard(model: Model): Board?
	local adornee = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if adornee == nil then
		return nil
	end
	local scope = Fusion.scoped(Fusion)
	local text = scope:Value("")
	local icon = scope:Value(nil)
	local visible = scope:Value(false)

	scope:New("BillboardGui")({
		Name = "CraftTimerBillboard",
		Adornee = adornee,
		Size = UDim2.fromOffset(150, 50),
		StudsOffsetWorldSpace = TableConfig.BillboardOffset,
		AlwaysOnTop = true,
		MaxDistance = 90,
		LightInfluence = 0,
		ResetOnSpawn = false,
		Enabled = visible,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		[Children] = {
			Panel(scope, {
				Name = "Pill",
				Size = UDim2.fromScale(1, 1),
				Color = Theme.Colors.Bar,
				Transparency = Theme.Transparency.Bar,
				Corner = UDim.new(1, 0),
				Padding = 6,
				Content = {
					Icon(scope, {
						Asset = icon,
						Size = UDim2.fromOffset(32, 32),
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						ZIndex = 3,
					}),
					Text(scope, {
						Name = "TimerText",
						Text = text,
						Weight = "Black",
						TextSize = 20,
						XAlignment = Enum.TextXAlignment.Center,
						Size = UDim2.new(1, -40, 1, 0),
						Position = UDim2.fromOffset(40, 0),
						ZIndex = 3,
					}),
				},
			}),
		},
	})
	return { scope = scope, text = text, icon = icon, visible = visible }
end

local function craftTimers(_world)
	if not Matter.useThrottle(0.1) then
		return
	end
	local now = workspace:GetServerTimeNow()
	local seen: { [Model]: boolean } = {}

	local plots = workspace:FindFirstChild(PlotConfig.FolderName)
	if plots then
		for _, plot in plots:GetChildren() do
			local model = plot:FindFirstChild(PlotConfig.SpawnedTableName)
			if model == nil or not model:IsA("Model") then
				continue
			end
			local recipeId = model:GetAttribute(TableConfig.CraftRecipeAttribute)
			local endsAt = model:GetAttribute(TableConfig.CraftEndsAtAttribute)
			if type(recipeId) ~= "string" or type(endsAt) ~= "number" or Recipes[recipeId] == nil then
				continue
			end
			seen[model] = true
			local board = boards[model] or createBoard(model)
			if board == nil then
				continue
			end
			boards[model] = board

			local remaining = math.ceil(endsAt - now)
			local text = if remaining > 0 then string.format(UIText.Seconds, remaining) else UIText.Done
			if peek(board.text) ~= text then
				board.text:set(text)
			end
			board.icon:set(UIAssets.Items[Recipes[recipeId].Output])
			board.visible:set(true)
		end
	end

	for model, board in boards do
		if not seen[model] then
			Fusion.doCleanup(board.scope)
			boards[model] = nil
		end
	end
end

return { system = craftTimers, priority = 10 }
