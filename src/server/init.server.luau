--!strict
-- Bootstrap server: data, bridge, lalu Matter loop.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Net = require(ReplicatedStorage.Shared.Net)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)
local DataService = require(script.Services.DataService)

-- Semua bridge dibuat di server lebih dulu supaya client bisa terhubung.
for _, name in NetworkConfig.Bridges do
	Net.bridge(name)
end

DataService.start()

local world = Matter.World.new()
local loop = Matter.Loop.new(world)

local systems = {}
for _, module in script.Systems:GetChildren() do
	if module:IsA("ModuleScript") then
		table.insert(systems, require(module) :: any)
	end
end

loop:scheduleSystems(systems)
loop:begin({ default = RunService.Heartbeat })
