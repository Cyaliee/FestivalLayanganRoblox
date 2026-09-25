--!strict
-- Sembunyikan prompt Papan Nama yang tidak relevan untuk pemain lokal:
-- - kavling milik orang lain
-- - kavling kosong kalau kita sudah punya kavling
-- Hanya kosmetik; server tetap memvalidasi semuanya.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local PlotConfig = require(ReplicatedStorage.Shared.Config.Plot)

local CHECK_INTERVAL = 0.25

local function plotPromptVisibility(_world)
	if not Matter.useThrottle(CHECK_INTERVAL) then
		return
	end

	local folder = workspace:FindFirstChild(PlotConfig.FolderName)
	if folder == nil then
		return
	end

	local myUserId = Players.LocalPlayer.UserId
	local plots = folder:GetChildren()

	local ownsPlot = false
	for _, plot in plots do
		if plot:GetAttribute(PlotConfig.OwnerAttribute) == myUserId then
			ownsPlot = true
			break
		end
	end

	for _, plot in plots do
		local sign = plot:FindFirstChild(PlotConfig.SignName)
		local prompt = sign and sign:FindFirstChild(PlotConfig.PromptName, true)
		if prompt and prompt:IsA("ProximityPrompt") then
			local ownerId = plot:GetAttribute(PlotConfig.OwnerAttribute)
			prompt.Enabled = if ownerId == nil then not ownsPlot else ownerId == myUserId
		end
	end
end

return { system = plotPromptVisibility, priority = 0 }
