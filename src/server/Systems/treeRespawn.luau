--!strict
-- Munculkan kembali pohon bambu yang sudah ditebang setelah RespawnTime.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.Components)
local Farming = require(ReplicatedStorage.Shared.Config.Farming)

local Bamboo = Farming.Bamboo

local function treeRespawn(world)
	local now = os.clock()
	local ready = {}
	for id, tree, felled in world:query(Components.BambooTree, Components.Felled) do
		if now >= felled.respawnAt then
			table.insert(ready, { id = id, tree = tree })
		end
	end
	for _, entry in ready do
		world:remove(entry.id, Components.Felled)
		world:insert(entry.id, Components.TreeHealth({ hp = Bamboo.MaxHp }))
		entry.tree.model:SetAttribute(Bamboo.HpAttribute, Bamboo.MaxHp)
		entry.tree.model.Parent = entry.tree.parent
	end
end

return { system = treeRespawn, priority = 46 }
