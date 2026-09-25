--!strict
-- Panel gaya Studded (tanpa interaksi). Lihat Block untuk semua props.
local Block = require(script.Parent.Block)

return function(scope: any, props: Block.Props): Instance
	return Block(scope, props)
end
