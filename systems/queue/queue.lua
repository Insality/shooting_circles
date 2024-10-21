local ecs = require("decore.ecs")
local decore = require("decore.decore")

---@class system.queue: system
local M = {}


---@static
---@return system.queue
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.id = "queue"

	return system
end


function M:postWrap()
	decore.queue:stash_to_events()
end


return M
