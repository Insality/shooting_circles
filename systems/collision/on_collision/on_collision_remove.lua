local ecs = require("decore.ecs")

---@class entity
---@field on_collision_remove boolean|nil

---@class entity.on_collision_remove: entity
---@field on_collision_remove boolean

---@class component.on_collision_remove: boolean

---@class system.on_collision_remove: system
---@field entities entity.on_collision_remove[]
local M = {}

local VECTOR_ZERO = vmath.vector3(0)


---@static
---@return system.on_collision_remove
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("collision_event")

	return system
end


---@param entity entity.on_collision_remove
function M:onAdd(entity)
	local collision_event = entity.collision_event
	if collision_event then
		self:process_collision_event(collision_event)
		self.world:removeEntity(entity)
	end
end


---@param collision_event component.collision_event
function M:process_collision_event(collision_event)
	local entity = collision_event.entity
	local on_collision_remove = entity.on_collision_remove
	if on_collision_remove then
		b2d.body.set_linear_velocity(entity.physics.box2d_body, VECTOR_ZERO)
		b2d.body.set_awake(entity.physics.box2d_body, false)
		self.world:removeEntity(entity)
	end
end


return M
