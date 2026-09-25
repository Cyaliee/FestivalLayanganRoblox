--!strict
-- Baca attribute layangan terbang dari Player lokal ke UIState (untuk bar di atas hotbar).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Kites = require(ReplicatedStorage.Shared.Config.Kites)
local Gamepasses = require(ReplicatedStorage.Shared.Config.Gamepasses)
local UIState = require(script.Parent.Parent.State.UIState)

local peek = Fusion.peek

local function setIfChanged(value: any, new: any)
	if peek(value) ~= new then
		value:set(new)
	end
end

local function flightStatus(_world)
	if not Matter.useThrottle(0.2) then
		return
	end
	local player = Players.LocalPlayer
	setIfChanged(UIState.FlightKite, player:GetAttribute(Kites.KiteAttribute))
	setIfChanged(UIState.FlightEndsAt, player:GetAttribute(Kites.EndsAtAttribute) or 0)
	setIfChanged(UIState.FlightDuration, player:GetAttribute(Kites.DurationAttribute) or 1)
	setIfChanged(UIState.Luck, player:GetAttribute(Gamepasses.LuckAttribute) or 1)
end

return { system = flightStatus, priority = 0 }
