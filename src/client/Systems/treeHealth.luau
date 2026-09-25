--!strict
-- Bar HP kecil di atas pohon bambu yang sedang ditebang (HP < MaxHP).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local World = require(ReplicatedStorage.Shared.Config.World)
local Farming = require(ReplicatedStorage.Shared.Config.Farming)
local ProgressBar = require(script.Parent.Parent.UI.Components.ProgressBar)

local Children = Fusion.Children
local Bamboo = Farming.Bamboo

type Bar = { scope: any, progress: any }
local bars: { [Instance]: Bar } = {}

local function adorneeOf(tree: Instance): BasePart?
	if tree:IsA("BasePart") then
		return tree
	end
	if tree:IsA("Model") then
		return tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function createBar(tree: Instance): Bar?
	local adornee = adorneeOf(tree)
	if adornee == nil then
		return nil
	end
	local scope = Fusion.scoped(Fusion)
	local progress = scope:Value(1)
	scope:New("BillboardGui")({
		Name = "TreeHealth",
		Adornee = adornee,
		Size = UDim2.fromOffset(110, 26),
		StudsOffsetWorldSpace = Vector3.new(0, 3, 0),
		AlwaysOnTop = true,
		MaxDistance = 60,
		LightInfluence = 0,
		ResetOnSpawn = false,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		[Children] = {
			ProgressBar(scope, {
				Progress = progress,
				Palette = "Green",
				Size = UDim2.new(1, 0, 1, -6),
			}),
		},
	})
	return { scope = scope, progress = progress }
end

local function treeHealth(_world)
	if not Matter.useThrottle(0.1) then
		return
	end
	local seen: { [Instance]: boolean } = {}
	local folder = workspace:FindFirstChild(World.BambooFolder)
	if folder then
		for _, tree in folder:GetChildren() do
			local hp = tree:GetAttribute(Bamboo.HpAttribute)
			local maxHp = tree:GetAttribute(Bamboo.MaxHpAttribute)
			if type(hp) ~= "number" or type(maxHp) ~= "number" or hp >= maxHp or hp <= 0 then
				continue
			end
			seen[tree] = true
			local bar = bars[tree] or createBar(tree)
			if bar then
				bars[tree] = bar
				bar.progress:set(hp / maxHp)
			end
		end
	end
	for tree, bar in bars do
		if not seen[tree] then
			Fusion.doCleanup(bar.scope)
			bars[tree] = nil
		end
	end
end

return { system = treeHealth, priority = 10 }
