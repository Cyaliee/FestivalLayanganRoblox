--!strict
-- Perbarui UIState.ServerTime (dipakai countdown crafting & layangan).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local UIState = require(script.Parent.Parent.State.UIState)

local INTERVAL = 0.1

local function clock(_world)
	if Matter.useThrottle(INTERVAL) then
		UIState.ServerTime:set(workspace:GetServerTimeNow())
	end
end

return { system = clock, priority = 0 }
