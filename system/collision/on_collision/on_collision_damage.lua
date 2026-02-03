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
	self.world.event_bus:process("collision_event", self.process_collision_events, self)
end


---@param collision_events system.collision.event[]
function M:process_collision_events(collision_events)
	for _, collision_event in ipairs(collision_events) do
		local entity = collision_event.entity
		if not self.indices[entity] then
			return
		end

		local damage = entity.on_collision_damage
		local other = collision_event.other
		if damage and other and other.health then
			self.world.health:apply_damage(other, damage)
		end
	end
end


return M
