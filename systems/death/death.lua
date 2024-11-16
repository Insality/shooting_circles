local decore = require("decore.decore")

---@class system.death: system
local M = {}


---@static
---@return system.death
function M.create_system()
	return decore.system(M, "death")
end


function M:postWrap()
	self.world.event_bus:process("health_event", self.process_health_event, self)
end


---@param health_event event.health_event
function M:process_health_event(health_event)
	if health_event.entity.health.current_health == 0 then
		self.world:removeEntity(health_event.entity)
	end
end


return M
