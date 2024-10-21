local decore = require("decore.decore")

---@class world
---@field transform_command system.transform_command

---@class system.transform_command: system
---@field transform system.transform
local M = {}


---@static
---@return system.transform_command
function M.create_system(transform)
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.transform = transform
	system.id = "transform_command"

	return system
end


---@private
function M:onAddToWorld()
	self.world.transform_command = self
end


---@private
function M:onRemoveFromWorld()
	self.world.transform_command = nil
end


---@param entity entity
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_position(entity, x, y, z)
	assert(entity.transform, "Entity does not have a transform component.")

	entity.transform.position_x = x or entity.transform.position_x
	entity.transform.position_y = y or entity.transform.position_y

	self.world.queue:push("transform_event", {
		entity = entity,
		is_position_changed = true
	})
end


---@param entity entity
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_scale(entity, x, y, z)
	assert(entity.transform, "Entity does not have a transform component.")

	entity.transform.scale_x = x or entity.transform.scale_x
	entity.transform.scale_y = y or entity.transform.scale_y

	self.world.queue:push("transform_event", {
		entity = entity,
		is_scale_changed = true
	})
end


---@param entity entity
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_size(entity, x, y, z)
	assert(entity.transform, "Entity does not have a transform component.")

	entity.transform.size_x = x or entity.transform.size_x
	entity.transform.size_y = y or entity.transform.size_y

	self.world.queue:push("transform_event", {
		entity = entity,
		is_size_changed = true
	})
end


function M:set_rotation(entity, rotation)
	assert(entity.transform, "Entity does not have a transform component.")

	entity.transform.rotation = rotation

	self.world.queue:push("transform_event", {
		entity = entity,
		is_rotation_changed = true
	})
end


---@param entity entity
---@param animate_time number|nil
---@param easing userdata|nil
function M:set_animate_time(entity, animate_time, easing)
	assert(entity.transform, "Entity does not have a transform component.")

	self.world.queue:push("transform_event", {
		entity = entity,
		animate_time = animate_time,
		easing = easing
	})
end


return M
