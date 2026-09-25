--!strict
--[[
	Antrean intent dari client (BridgeNet2) supaya diproses oleh system Matter tiap frame.
	Intent tidak membawa angka/nilai dari client; payload hanya disimpan kalau system butuh
	(dan harus divalidasi di system).

	IntentQueue.listen("RequestBagUpgrade")    -- panggil sekali saat module system di-require
	for _, intent in IntentQueue.drain("RequestBagUpgrade") do ... intent.player, intent.payload
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)

export type Intent = { player: Player, payload: any }

local IntentQueue = {}

local queues: { [string]: { Intent } } = {}

function IntentQueue.listen(bridgeName: string)
	if queues[bridgeName] then
		return
	end
	local queue: { Intent } = {}
	queues[bridgeName] = queue
	Net.bridge(bridgeName):Connect(function(player: Player, payload: any)
		table.insert(queue, { player = player, payload = payload })
	end)
end

-- Ambil & kosongkan semua intent yang menunggu
function IntentQueue.drain(bridgeName: string): { Intent }
	local queue = queues[bridgeName]
	if queue == nil or #queue == 0 then
		return {}
	end
	local items = table.clone(queue)
	table.clear(queue)
	return items
end

return IntentQueue
