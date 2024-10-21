local ecs = require("decore.ecs")

---@class system.death: system
local M = {}


---@static
---@return system.death
function M.create_system()
	return setmetatable(ecs.system(), { __index = M })
end


function M:postWrap()
	self.world.queue:process("health_event", self.process_health_event, self)
end


---@param health_event event.health_event
function M:process_health_event(health_event)
	if not health_event.damage then
		return
	end

	if health_event.entity.health.current_health == 0 then
		self.world:removeEntity(health_event.entity)
	end
end


return M
