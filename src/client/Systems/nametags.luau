--!strict
-- Nametag di atas kepala semua pemain: "DisplayName | Lv.xxx" (Fusion, dibuat di client).
-- Level dari attribute "Level" yang diisi server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIText = require(ReplicatedStorage.Shared.Config.UIText)
local Text = require(script.Parent.Parent.UI.Components.Text)
local PlayerState = require(script.Parent.Parent.State.PlayerState)

local peek = Fusion.peek
local Children = Fusion.Children

type Tag = { scope: any, text: any, adornee: any }
local tags: { [Player]: Tag } = {}

local function createTag(player: Player): Tag
	local scope = Fusion.scoped(Fusion)
	local text = scope:Value("")
	local adornee = scope:Value(nil)
	scope:New("BillboardGui")({
		Name = "Nametag_" .. player.Name,
		Adornee = adornee,
		Size = UDim2.fromOffset(220, 30),
		StudsOffsetWorldSpace = Vector3.new(0, 2.4, 0),
		AlwaysOnTop = false,
		MaxDistance = 90,
		LightInfluence = 0,
		ResetOnSpawn = false,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		[Children] = {
			Text(scope, {
				Name = "NameText",
				Text = text,
				Weight = "Bold",
				TextSize = 16,
				XAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromScale(1, 1),
				Outline = true,
			}),
		},
	})
	return { scope = scope, text = text, adornee = adornee }
end

local function nametags(_world)
	if not Matter.useThrottle(0.25) then
		return
	end
	local seen: { [Player]: boolean } = {}
	local enabled = peek(PlayerState.Settings).ShowNametags ~= false
	for _, player in Players:GetPlayers() do
		if not enabled then
			break
		end
		local head = player.Character and player.Character:FindFirstChild("Head")
		if head == nil then
			continue
		end
		seen[player] = true
		local tag = tags[player] or createTag(player)
		tags[player] = tag
		local level = player:GetAttribute("Level")
		local text = string.format(UIText.Nametag, player.DisplayName, if type(level) == "number" then level else 1)
		if peek(tag.text) ~= text then
			tag.text:set(text)
		end
		if peek(tag.adornee) ~= head then
			tag.adornee:set(head)
		end
	end
	for player, tag in tags do
		if not seen[player] then
			Fusion.doCleanup(tag.scope)
			tags[player] = nil
		end
	end
end

return { system = nametags, priority = 10 }
