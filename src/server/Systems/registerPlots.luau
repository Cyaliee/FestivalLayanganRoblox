--!strict
-- Daftarkan Workspace/Plots/* sebagai entity Plot. Plot baru/yang dihapus saat runtime ikut ditangani.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.Components)
local PlotConfig = require(ReplicatedStorage.Shared.Config.Plot)
local warnOnce = require(script.Parent.Parent.Util.WarnOnce)

local Plot = Components.Plot

local function findPromptParent(sign: Instance): BasePart?
	if sign:IsA("BasePart") then
		return sign
	end
	if sign:IsA("Model") and sign.PrimaryPart then
		return sign.PrimaryPart
	end
	return sign:FindFirstChildWhichIsA("BasePart", true)
end

local function setupPrompt(plotModel: Model, sign: Instance): ProximityPrompt?
	local prompt = sign:FindFirstChild(PlotConfig.PromptName, true)
	if prompt == nil then
		local parent = findPromptParent(sign)
		if parent == nil then
			warn(`[Plots] {sign:GetFullName()} tidak punya BasePart untuk ProximityPrompt`)
			return nil
		end
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = PlotConfig.PromptName
		prompt.Parent = parent
	elseif not prompt:IsA("ProximityPrompt") then
		warn(`[Plots] {prompt:GetFullName()} harus ProximityPrompt`)
		return nil
	end

	local p = prompt :: ProximityPrompt
	p.ActionText = PlotConfig.ClaimActionText
	p.ObjectText = PlotConfig.ObjectText
	p.HoldDuration = PlotConfig.HoldDuration
	p.MaxActivationDistance = PlotConfig.MaxActivationDistance
	p.RequiresLineOfSight = false
	return p
end

-- World yang sudah di-scan awal (tidak pakai useHookState: fungsi hook lokal bisa di-inline Luau)
local scannedWorlds: { [any]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local function registerPlot(world, plotModel: Instance)
	if not plotModel:IsA("Model") then
		warn(`[Plots] {plotModel:GetFullName()} bukan Model, dilewati`)
		return
	end

	local sign = plotModel:FindFirstChild(PlotConfig.SignName)
	if sign == nil or not sign:IsA("PVInstance") then
		warn(`[Plots] {plotModel:GetFullName()} tidak punya {PlotConfig.SignName} (Part/Model), dilewati`)
		return
	end

	local prompt = setupPrompt(plotModel, sign)
	if prompt == nil then
		return
	end

	local tableSpawn: CFrame
	local spawnPart = plotModel:FindFirstChild(PlotConfig.TableSpawnName)
	if spawnPart and spawnPart:IsA("BasePart") then
		tableSpawn = spawnPart.CFrame
	else
		warn(`[Plots] {plotModel:GetFullName()} tidak punya Part {PlotConfig.TableSpawnName}, pakai pivot plot`)
		tableSpawn = plotModel:GetPivot()
	end

	local ownerText = sign:FindFirstChild(PlotConfig.OwnerTextName, true)
	if ownerText and ownerText:IsA("TextLabel") then
		ownerText.Text = PlotConfig.EmptyOwnerText
	else
		ownerText = nil
		warnOnce(
			`ownertext:{plotModel:GetFullName()}`,
			`[Plots] {sign:GetFullName()} tidak punya TextLabel {PlotConfig.OwnerTextName} (opsional)`
		)
	end

	plotModel:SetAttribute(PlotConfig.OwnerAttribute, nil)

	world:spawn(Plot({
		model = plotModel,
		sign = sign,
		prompt = prompt,
		tableSpawn = tableSpawn,
		ownerText = ownerText,
	}))
end

local function registerPlots(world)
	local folder = workspace:FindFirstChild(PlotConfig.FolderName)
	if folder == nil then
		warnOnce("plotsfolder", `[Plots] Workspace/{PlotConfig.FolderName} tidak ada`)
		return
	end

	if not scannedWorlds[world] then
		scannedWorlds[world] = true
		for _, child in folder:GetChildren() do
			registerPlot(world, child)
		end
	end

	for _, child in Matter.useEvent(folder, "ChildAdded") do
		registerPlot(world, child)
	end

	-- Plot yang dihapus dari Workspace
	local removed = {}
	for id, plot in world:query(Plot) do
		if plot.model.Parent ~= folder then
			table.insert(removed, id)
		end
	end
	for _, id in removed do
		world:despawn(id)
	end
end

return { system = registerPlots, priority = 0 }
