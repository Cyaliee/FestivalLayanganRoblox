--!strict
-- Reaksi terhadap perubahan Owner: teks prompt, teks papan nama, attribute untuk client.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Shared.Components)
local PlotConfig = require(ReplicatedStorage.Shared.Config.Plot)

local Plot = Components.Plot
local Owner = Components.Owner

local function plotVisuals(world)
	for id, record in world:queryChanged(Owner) do
		if not world:contains(id) then
			continue
		end
		local plot = world:get(id, Plot)
		if plot == nil then
			continue
		end

		local owner = record.new
		if owner then
			plot.prompt.ActionText = PlotConfig.OwnedActionText
			plot.model:SetAttribute(PlotConfig.OwnerAttribute, owner.userId)
			if plot.ownerText then
				plot.ownerText.Text = string.format(PlotConfig.OwnerTextFormat, owner.player.DisplayName)
			end
		else
			plot.prompt.ActionText = PlotConfig.ClaimActionText
			plot.model:SetAttribute(PlotConfig.OwnerAttribute, nil)
			if plot.ownerText then
				plot.ownerText.Text = PlotConfig.EmptyOwnerText
			end
		end
	end
end

return { system = plotVisuals, priority = 40 }
