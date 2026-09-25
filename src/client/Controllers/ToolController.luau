--!strict
-- Kapak: saat tool diayun (klik / tap), kirim intent RequestChop (tanpa data).
-- Server yang mencari pohon terdekat & memvalidasi jarak/cooldown.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local Farming = require(ReplicatedStorage.Shared.Config.Farming)
local NetworkConfig = require(ReplicatedStorage.Shared.Config.Network)

local ToolController = {}

local lastSwing = 0

function ToolController.start()
	local chopBridge = Net.bridge(NetworkConfig.Bridges.RequestChop)

	local function hookTool(tool: Instance)
		if not tool:IsA("Tool") or tool.Name ~= Farming.Axe.ToolName or tool:GetAttribute("Hooked") then
			return
		end
		tool:SetAttribute("Hooked", true)
		tool.Activated:Connect(function()
			local now = os.clock()
			if now - lastSwing < Farming.Axe.SwingCooldown then
				return
			end
			lastSwing = now
			chopBridge:Fire({})
		end)
	end

	local function hookCharacter(character: Model)
		for _, child in character:GetChildren() do
			hookTool(child)
		end
		character.ChildAdded:Connect(hookTool)
	end

	local player = Players.LocalPlayer
	if player.Character then
		hookCharacter(player.Character)
	end
	player.CharacterAdded:Connect(hookCharacter)
end

return ToolController
