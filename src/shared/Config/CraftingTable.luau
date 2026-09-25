--!strict
-- Meja Rakit: level, biaya upgrade, kecepatan merakit, prompt.

export type TableLevel = {
	UpgradeCost: number?, -- biaya naik ke level berikutnya (nil = level maksimal)
	Speed: number, -- pengali kecepatan merakit
}

local Levels: { TableLevel } = {
	{ UpgradeCost = 300, Speed = 1 },
	{ UpgradeCost = 1200, Speed = 1.25 },
	{ UpgradeCost = 4000, Speed = 1.5 },
	{ UpgradeCost = 12000, Speed = 1.75 },
	{ UpgradeCost = nil, Speed = 2 },
}

return table.freeze({
	Levels = Levels,
	MaxLevel = #Levels,

	-- ProximityPrompt di MejaRakit
	PromptName = "CraftPrompt",
	PromptActionText = "Rakit Layangan",
	PromptObjectText = "Meja Rakit",
	PromptHoldDuration = 0.3,
	InteractDistance = 10,
	DistanceTolerance = 8,

	-- Attribute di model MejaRakit (dibaca client untuk billboard timer)
	LevelAttribute = "Level",
	OwnerAttribute = "OwnerUserId",
	CraftRecipeAttribute = "CraftRecipe",
	CraftEndsAtAttribute = "CraftEndsAt",
	BillboardOffset = Vector3.new(0, 4, 0),
})
