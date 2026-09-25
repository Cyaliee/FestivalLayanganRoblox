--!strict
-- Bootstrap client: controller UI, lalu Matter loop.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Matter = require(ReplicatedStorage.Packages.Matter)

for _, module in script.Controllers:GetChildren() do
	if module:IsA("ModuleScript") then
		(require(module) :: any).start()
	end
end

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
