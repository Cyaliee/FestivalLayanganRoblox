--!strict
-- Pengumuman global ke layar semua pemain.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)

return function(text: string, palette: string?)
	Net.bridge(NetworkConfig.Bridges.Announce):Fire(Net.allPlayers(), { Text = text, Palette = palette })
end
