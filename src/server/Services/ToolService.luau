--!strict
-- Tool pemain (kapak). Diambil dari ServerStorage/Assets/Tools, atau dibuat placeholder kalau tidak ada.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local World = require(ReplicatedStorage.Shared.Config.World)
local Farming = require(ReplicatedStorage.Shared.Config.Farming)
local warnOnce = require(script.Parent.Parent.Util.WarnOnce)

local ToolService = {}

local function makePlaceholderAxe(): Tool
	local tool = Instance.new("Tool")
	tool.Name = Farming.Axe.ToolName
	tool.CanBeDropped = false
	tool.RequiresHandle = true

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 3, 0.4)
	handle.Color = Color3.fromRGB(120, 80, 40)
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(0.3, 0.9, 1.2)
	head.Color = Color3.fromRGB(170, 170, 180)
	head.Material = Enum.Material.Metal
	head.CanCollide = false
	head.Massless = true
	head.CFrame = handle.CFrame * CFrame.new(0, 1.2, -0.5)
	head.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = head
	weld.Parent = handle

	tool.Grip = CFrame.new(0, -1, 0)
	return tool
end

local function getAxeTemplate(): Tool
	local assets = ServerStorage:FindFirstChild(World.AssetFolder)
	local tools = assets and assets:FindFirstChild(World.ToolsFolder)
	local tool = tools and tools:FindFirstChild(Farming.Axe.ToolName)
	if tool and tool:IsA("Tool") then
		return tool
	end
	warnOnce(
		"axetool",
		`[Tools] ServerStorage/{World.AssetFolder}/{World.ToolsFolder}/{Farming.Axe.ToolName} tidak ada, pakai kapak placeholder`
	)
	local placeholder = makePlaceholderAxe()
	return placeholder
end

local axeTemplate: Tool? = nil

-- Pastikan pemain punya kapak di Backpack/karakter
function ToolService.ensureAxe(player: Player): Tool?
	local name = Farming.Axe.ToolName
	local backpack = player:FindFirstChildOfClass("Backpack")
	local character = player.Character
	local existing = (character and character:FindFirstChild(name)) or (backpack and backpack:FindFirstChild(name))
	if existing and existing:IsA("Tool") then
		return existing
	end
	if backpack == nil then
		return nil
	end
	if axeTemplate == nil then
		axeTemplate = getAxeTemplate()
	end
	local tool = (axeTemplate :: Tool):Clone()
	tool.Parent = backpack
	return tool
end

function ToolService.isHoldingAxe(player: Player): boolean
	local character = player.Character
	local tool = character and character:FindFirstChild(Farming.Axe.ToolName)
	return tool ~= nil and tool:IsA("Tool")
end

function ToolService.equipAxe(player: Player)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local tool = ToolService.ensureAxe(player)
	if humanoid and tool and tool.Parent ~= player.Character then
		humanoid:EquipTool(tool)
	end
end

function ToolService.unequip(player: Player)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:UnequipTools()
	end
end

-- Animasi ayun bawaan (Animate script membaca StringValue "toolanim")
function ToolService.playSwing(player: Player)
	local character = player.Character
	local tool = character and character:FindFirstChild(Farming.Axe.ToolName)
	if tool then
		local anim = Instance.new("StringValue")
		anim.Name = "toolanim"
		anim.Value = "Slash"
		anim.Parent = tool
		game:GetService("Debris"):AddItem(anim, 1)
	end
end

return ToolService
