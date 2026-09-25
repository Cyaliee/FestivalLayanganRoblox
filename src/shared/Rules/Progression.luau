--!strict
local Config = require(script.Parent.Parent.Config.Progression)

local Progression = {}

-- EXP yang dibutuhkan dari level ini ke level berikutnya
function Progression.expToNext(level: number): number
	return math.floor(Config.ExpBase * Config.ExpGrowth ^ (math.max(level, 1) - 1))
end

function Progression.isMaxLevel(level: number): boolean
	return level >= Config.MaxLevel
end

return Progression
