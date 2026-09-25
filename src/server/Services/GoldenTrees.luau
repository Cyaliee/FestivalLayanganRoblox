--!strict
-- Ubah pohon bambu biasa jadi Pohon Bambu Emas (dan kembalikan). Visual: Highlight + cahaya.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.Components)
local Farming = require(ReplicatedStorage.Shared.Config.Farming)

local Golden = Farming.Golden
local Bamboo = Farming.Bamboo

local EFFECT_NAMES = { "GoldenHighlight", "GoldenLight", "GoldenSparkles" }

local GoldenTrees = {}

local function effectParent(model: Instance): Instance?
	if model:IsA("BasePart") then
		return model
	end
	return (model :: any).PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
end

function GoldenTrees.makeGolden(world, treeId: number, now: number)
	local tree = world:get(treeId, Components.BambooTree)
	if tree == nil then
		return
	end
	local model = tree.model
	world:insert(treeId, Components.GoldenTree({ expiresAt = now + Golden.Lifetime }))
	world:insert(treeId, Components.TreeHealth({ hp = Golden.MaxHp }))
	model:SetAttribute(Golden.Attribute, true)
	model:SetAttribute(Bamboo.HpAttribute, Golden.MaxHp)
	model:SetAttribute(Bamboo.MaxHpAttribute, Golden.MaxHp)

	local highlight = Instance.new("Highlight")
	highlight.Name = "GoldenHighlight"
	highlight.FillColor = Golden.Color
	highlight.FillTransparency = 0.35
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.Parent = model

	local part = effectParent(model)
	if part then
		local light = Instance.new("PointLight")
		light.Name = "GoldenLight"
		light.Color = Golden.Color
		light.Range = 24
		light.Brightness = 3
		light.Parent = part

		local sparkles = Instance.new("Sparkles")
		sparkles.Name = "GoldenSparkles"
		sparkles.SparkleColor = Golden.Color
		sparkles.Parent = part
	end
end

-- Kembalikan jadi pohon biasa (setelah ditebang / kedaluwarsa)
function GoldenTrees.revert(world, treeId: number)
	local tree = world:get(treeId, Components.BambooTree)
	if world:get(treeId, Components.GoldenTree) then
		world:remove(treeId, Components.GoldenTree)
	end
	if tree == nil then
		return
	end
	local model = tree.model
	model:SetAttribute(Golden.Attribute, nil)
	model:SetAttribute(Bamboo.MaxHpAttribute, Bamboo.MaxHp)
	for _, name in EFFECT_NAMES do
		local effect = model:FindFirstChild(name, true)
		if effect then
			effect:Destroy()
		end
	end
end

return GoldenTrees
