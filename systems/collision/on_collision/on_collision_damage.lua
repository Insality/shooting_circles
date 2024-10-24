local decore = require("decore.decore")

---@class entity
---@field on_collision_damage component.on_collision_damage|nil

---@class entity.on_collision_damage: entity
---@field on_collision_damage component.on_collision_damage

---@class component.on_collision_damage
---@field damage number
decore.register_component("on_collision_damage", {
	damage = 0
})

---@class system.on_collision_damage: system
---@field entities entity.on_collision_damage[]
local M = {}


---@static
---@return system.on_collision_damage
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("on_collision_damage")
	system.id = "on_collision_damage"

	return system
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

	local damage = entity.on_collision_damage.damage
	local other = collision_event.other
	if other and other.health then
		self.world.health_command:apply_damage(other, damage)
	end
end


return M
