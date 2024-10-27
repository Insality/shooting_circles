local decore = require("decore.decore")

---@class entity
---@field on_collision_damage number|nil

---@class entity.on_collision_damage: entity
---@field on_collision_damage number

decore.register_component("on_collision_damage", 0)

---@class system.on_collision_damage: system
---@field entities entity.on_collision_damage[]
local M = {}


---@static
---@return system.on_collision_damage
function M.create_system()
	return decore.system(M, "on_collision_damage", "on_collision_damage")
end


function M:postWrap()
	self.world.queue:process("collision_event", self.process_collision_event, self)
end


---@param collision_event event.collision_event
function M:process_collision_event(collision_event)
	local entity = collision_event.entity
	if not decore.is_alive(self, entity) then
		return
	end

	local damage = entity.on_collision_damage
	local other = collision_event.other
	if damage and other and other.health then
		self.world.health_command:apply_damage(other, damage)
	end
end


return M
