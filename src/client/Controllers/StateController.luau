--!strict
-- Terima snapshot data pemain dari server dan simpan ke PlayerState.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local PlayerState = require(script.Parent.Parent.State.PlayerState)

local StateController = {}

function StateController.start()
	Net.bridge(NetworkConfig.Bridges.PlayerState):Connect(function(snapshot)
		PlayerState.apply(snapshot)
	end)
	-- Minta snapshot sekarang, kalau-kalau kiriman pertama terjadi sebelum listener terpasang
	Net.bridge(NetworkConfig.Bridges.RequestState):Fire({})
end

return StateController
