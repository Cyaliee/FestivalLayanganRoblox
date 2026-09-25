--!strict
-- Rate limiter sliding-window per pemain. Angka diambil dari Config/Network.RateLimits.
local Players = game:GetService("Players")

local RateLimiter = {}
RateLimiter.__index = RateLimiter

export type RateLimiter = typeof(setmetatable(
	{} :: { max: number, window: number, hits: { [Player]: { number } } },
	RateLimiter
))

local all: { RateLimiter } = {}

function RateLimiter.new(rule: { Max: number, Window: number }): RateLimiter
	local self = setmetatable({ max = rule.Max, window = rule.Window, hits = {} }, RateLimiter)
	table.insert(all, self)
	return self
end

-- true = boleh lanjut, false = kena limit
function RateLimiter.check(self: RateLimiter, player: Player): boolean
	local now = os.clock()
	local list = self.hits[player]
	if list == nil then
		list = {}
		self.hits[player] = list
	end

	-- buang hit yang sudah lewat window
	local cutoff = now - self.window
	while list[1] ~= nil and list[1] < cutoff do
		table.remove(list, 1)
	end

	if #list >= self.max then
		return false
	end
	table.insert(list, now)
	return true
end

Players.PlayerRemoving:Connect(function(player)
	for _, limiter in all do
		limiter.hits[player] = nil
	end
end)

return RateLimiter
