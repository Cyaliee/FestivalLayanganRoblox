--!strict
-- Akses bridge BridgeNet2. Nama bridge hanya boleh dari Config/Network.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local NetworkConfig = require(script.Parent.Config.Network)

local Net = {}

local cache: { [string]: any } = {}

function Net.bridge(name: string): any
	assert(NetworkConfig.Bridges[name] ~= nil, `[Net] Bridge "{name}" tidak terdaftar di Config/Network`)
	local bridge = cache[name]
	if not bridge then
		bridge = BridgeNet2.ReferenceBridge(name)
		cache[name] = bridge
	end
	return bridge
end

-- Hanya server: target untuk :Fire()
function Net.allPlayers(): any
	return BridgeNet2.AllPlayers()
end

return Net
