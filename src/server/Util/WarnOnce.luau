--!strict
-- warn() yang hanya muncul sekali per key (system jalan tiap frame).
local warned: { [string]: boolean } = {}

return function(key: string, message: string)
	if warned[key] then
		return
	end
	warned[key] = true
	warn(message)
end
