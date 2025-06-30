local evolved = require("evolved")
local fragments = require("fragments")


local M = {}


function M.create_system()
	return evolved.builder()
		:name("All Entities")
		:set(fragments.system)
		:spawn()
end


return M
