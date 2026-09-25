--!strict
-- EXP yang dibutuhkan untuk naik level: floor(ExpBase * ExpGrowth^(level-1))

return table.freeze({
	ExpBase = 100,
	ExpGrowth = 1.35,
	MaxLevel = 100,
})
