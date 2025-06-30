local evolved = require("evolved")

---@class components: table<string, evolved.id>
local M = {
	dt = evolved.builder():name("dt"):default(0):spawn(),
	system = evolved.builder():name("system"):tag():spawn(),
}

return M
