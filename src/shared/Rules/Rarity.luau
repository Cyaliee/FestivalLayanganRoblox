--!strict
-- Acak rarity dengan bobot, luck, dan booster Bambu Emas.
local RarityConfig = require(script.Parent.Parent.Config.Rarity)

local Rarity = {}

function Rarity.weights(luck: number, boosted: boolean): { [string]: number }
	local weights = {}
	for _, id in RarityConfig.Order do
		local tier = RarityConfig.Tiers[id]
		local weight = if boosted then tier.BoostedWeight else tier.Weight
		if not RarityConfig.LuckExcluded[id] then
			weight *= luck
		end
		weights[id] = weight
	end
	return weights
end

-- Peluang (0..1) tiap tier, untuk ditampilkan di UI
function Rarity.chances(luck: number, boosted: boolean): { [string]: number }
	local weights = Rarity.weights(luck, boosted)
	local total = 0
	for _, weight in weights do
		total += weight
	end
	local chances = {}
	for id, weight in weights do
		chances[id] = if total > 0 then weight / total else 0
	end
	return chances
end

function Rarity.roll(luck: number, boosted: boolean, rng: Random?): string
	local weights = Rarity.weights(luck, boosted)
	local total = 0
	for _, weight in weights do
		total += weight
	end
	local pick = (rng or Random.new()):NextNumber() * total
	for _, id in RarityConfig.Order do
		pick -= weights[id]
		if pick <= 0 and weights[id] > 0 then
			return id
		end
	end
	return RarityConfig.Order[1]
end

function Rarity.atLeast(rarity: string, minimum: string): boolean
	local a = RarityConfig.Tiers[rarity]
	local b = RarityConfig.Tiers[minimum]
	return a ~= nil and b ~= nil and a.Rank >= b.Rank
end

return Rarity
