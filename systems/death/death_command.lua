local ecs = require("decore.ecs")
local decore = require("decore.decore")

---@class entity
---@field death_command component.death_command|nil

---@class entity.death_command: entity
---@field death_command component.death_command

---@class component.death_command

---@class system.death_command: system
---@field entities entity.death_command[]
---@field death system.death
local M = {}


---@static
---@return system.death_command
function M.create_system(death)
	local system = setmetatable(ecs.system(), { __index = M })
	system.death = death

	return system
end


function M:postWrap()
	self.world.queue:process("health_event", self.process_health_event, self)
end


---@param health_event event.health_event
function M:process_health_event(health_event)
	if health_event.damage then
		if health_event.entity.health.current_health == 0 then
			self.world:removeEntity(health_event.entity)
		end
	end
end


return M
