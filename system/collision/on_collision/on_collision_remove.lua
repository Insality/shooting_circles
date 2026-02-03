local decore = require("decore.decore")

---@class entity
---@field on_collision_remove boolean|nil

---@class entity.on_collision_remove: entity
---@field on_collision_remove boolean
decore.register_component("on_collision_remove", false)

---@class system.on_collision_remove: system
---@field entities entity.on_collision_remove[]
local M = {}

---@static
---@return system.on_collision_remove
function M.create_system()
	return decore.system(M, "on_collision_remove", { "physics" })
end


function M:postWrap()
	self.world.event_bus:process("collision_event", self.process_collision_events, self)
end


---@param collision_events system.collision.event[]
function M:process_collision_events(collision_events)
	for _, collision_event in ipairs(collision_events) do
		local entity = collision_event.entity
		local on_collision_remove = entity.on_collision_remove
		if on_collision_remove then
			--b2d.body.set_linear_velocity(entity.physics.box2d_body, VECTOR_ZERO)
			--b2d.body.set_awake(entity.physics.box2d_body, false)
			self.world:removeEntity(entity)
		end
	end
end


return M
