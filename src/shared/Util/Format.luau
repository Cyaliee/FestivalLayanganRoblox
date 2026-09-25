--!strict
-- Format angka untuk UI: 1250 -> "1.250", 2500000 -> "2,5jt"
local UIText = require(script.Parent.Parent.Config.UIText)

local Format = {}

function Format.number(n: number): string
	n = math.floor(n)
	for _, rule in UIText.CompactSuffixes do
		if math.abs(n) >= rule.Value then
			local scaled = math.floor(n / rule.Value * 10) / 10
			local text = if scaled % 1 == 0 then string.format("%d", scaled) else string.format("%.1f", scaled)
			return (string.gsub(text, "%.", ",")) .. rule.Suffix
		end
	end

	local digits = tostring(math.abs(n))
	local grouped = string.reverse((string.gsub(string.reverse(digits), "(%d%d%d)", "%1" .. UIText.ThousandSeparator)))
	if string.sub(grouped, 1, 1) == UIText.ThousandSeparator then
		grouped = string.sub(grouped, 2)
	end
	return if n < 0 then "-" .. grouped else grouped
end

return Format
