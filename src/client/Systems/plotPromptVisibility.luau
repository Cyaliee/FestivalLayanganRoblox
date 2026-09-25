--!strict
-- Sembunyikan prompt yang tidak relevan untuk pemain lokal:
-- - prompt Naga di meja orang lain / kalau tidak punya naga
-- - kavling milik orang lain
-- - kavling kosong kalau kita sudah punya kavling
-- Hanya kosmetik; server tetap memvalidasi semuanya.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local PlotConfig = require(ReplicatedStorage.Shared.Config.Plot)
local Dragon = require(ReplicatedStorage.Shared.Config.Dragon)
local TableConfig = require(ReplicatedStorage.Shared.Config.CraftingTable)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ItemKey = require(ReplicatedStorage.Shared.Rules.ItemKey)
local PlayerState = require(script.Parent.Parent.State.PlayerState)

local CHECK_INTERVAL = 0.25

local function plotPromptVisibility(_world)
	if not Matter.useThrottle(CHECK_INTERVAL) then
		return
	end

	local folder = workspace:FindFirstChild(PlotConfig.FolderName)
	if folder == nil then
		return
	end

	local myUserId = Players.LocalPlayer.UserId
	local plots = folder:GetChildren()

	local ownsPlot = false
	for _, plot in plots do
		if plot:GetAttribute(PlotConfig.OwnerAttribute) == myUserId then
			ownsPlot = true
			break
		end
	end

	-- Punya Layangan Naga di tas?
	local hasDragon = false
	for key, count in Fusion.peek(PlayerState.Inventory) do
		if count > 0 and ItemKey.parse(key) == Dragon.ItemId then
			hasDragon = true
			break
		end
	end

	for _, plot in plots do
		-- Prompt naga: hanya pemilik meja, dan hanya kalau punya naga / naga sedang terpasang
		local tableModel = plot:FindFirstChild(PlotConfig.SpawnedTableName)
		local dragonPrompt = tableModel and tableModel:FindFirstChild(Dragon.PromptName, true)
		if dragonPrompt and dragonPrompt:IsA("ProximityPrompt") then
			local isOwner = tableModel:GetAttribute(TableConfig.OwnerAttribute) == myUserId
			local placed = tableModel:GetAttribute(Dragon.PlacedAttribute) == true
			dragonPrompt.Enabled = isOwner and (placed or hasDragon)
		end

		local sign = plot:FindFirstChild(PlotConfig.SignName)
		local prompt = sign and sign:FindFirstChild(PlotConfig.PromptName, true)
		if prompt and prompt:IsA("ProximityPrompt") then
			local ownerId = plot:GetAttribute(PlotConfig.OwnerAttribute)
			prompt.Enabled = if ownerId == nil then not ownsPlot else ownerId == myUserId
		end
	end
end

return { system = plotPromptVisibility, priority = 0 }
