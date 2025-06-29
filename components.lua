local evolved = require("evolved")

---@class components: table<string, evolved.id>
local M = {
	dt = evolved.builder():name("dt"):default(0):spawn(),
	system = evolved.builder():name("system"):tag():spawn(),
	single_update = evolved.builder():name("single_update"):spawn(),
}
evolved.set(M.single_update, M.single_update)

return M
