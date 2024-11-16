local ecs = require("decore.ecs")

---@class system.event_bus: system
local M = {}


---@return system.event_bus
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.id = "event_bus"

	return system
end


function M:postWrap()
	self.world.event_bus:stash_to_events()
end


return M
