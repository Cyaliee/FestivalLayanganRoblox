--!strict
-- Kirim notifikasi ke HUD pemain.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)

return function(player: Player, text: string)
	Net.bridge(NetworkConfig.Bridges.Notify):Fire(player, { Text = text })
end
