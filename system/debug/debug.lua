local evolved = require("evolved")
local components = require("components")


local M = {}


function M.create_system()
	return evolved.builder()
		:name("All Entities")
		:set(components.system)
		:spawn()
end


return M
