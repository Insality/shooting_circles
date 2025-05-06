local decore = require("decore.decore")
local command_transform = require("system.transform.command_transform")

---@class entity
---@field transform component.transform|nil

---@class entity.transform: entity
---@field transform component.transform

---@class entity.command_transform: entity
---@field transform component.transform

---@class component.transform
---@field position_x number The position x
---@field position_y number The position y
---@field position_z number The position z
---@field size_x number The size x
---@field size_y number The size y
---@field size_z number The size z
---@field scale_x number The scale x
---@field scale_y number The scale y
---@field scale_z number The scale z
---@field rotation number The rotation
decore.register_component("transform", {
	position_x = 0,
	position_y = 0,
	position_z = 0,
	size_x = 1,
	size_y = 1,
	size_z = 1,
	scale_x = 1,
	scale_y = 1,
	scale_z = 1,
	rotation = 0,
})

---@class system.transform.event
---@field entity entity.transform The entity that was changed.
---@field is_position_changed boolean|nil If true, the position was changed.
---@field is_scale_changed boolean|nil If true, the scale was changed.
---@field is_rotation_changed boolean|nil If true, the rotation was changed.
---@field is_size_changed boolean|nil If true, the size was changed.
---@field animate_time number|nil If true, the time it took to animate the transform.
---@field easing userdata|nil The easing function used for the animation.

---@class system.transform: system
---@field entities entity.transform[]
local M = {}


---@return system.transform
function M.create_system()
	return decore.system(M, "transform", "transform")
end


function M:onAddToWorld()
	self.world.command_transform = command_transform.create(self)
	self.world.event_bus:set_merge_policy("transform_event", self.event_merge_policy)
end


---@param entity entity.transform
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_position(entity, x, y, z)
	local t = entity.transform
	local is_changed = (x and t.position_x ~= x) or (y and t.position_y ~= y) or (z and t.position_z ~= z)

	t.position_x = x or t.position_x
	t.position_y = y or t.position_y
	t.position_z = z or t.position_z

	if is_changed then
		self.world.event_bus:trigger("transform_event", {
			entity = entity,
			is_position_changed = true,
		})
	end
end


---@param entity entity.transform
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_scale(entity, x, y, z)
	local t = entity.transform
	local is_changed = (x and t.scale_x ~= x) or (y and t.scale_y ~= y) or (z and t.scale_z ~= z)

	t.scale_x = x or t.scale_x
	t.scale_y = y or t.scale_y
	t.scale_z = z or t.scale_z

	if is_changed then
		self.world.event_bus:trigger("transform_event", {
			entity = entity,
			is_scale_changed = true,
		})
	end
end


---@param entity entity.transform
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_size(entity, x, y, z)
	local t = entity.transform
	local is_changed = (x and t.size_x ~= x) or (y and t.size_y ~= y) or (z and t.size_z ~= z)

	t.size_x = x or t.size_x
	t.size_y = y or t.size_y
	t.size_z = z or t.size_z

	if is_changed then
		self.world.event_bus:trigger("transform_event", {
			entity = entity,
			is_size_changed = true,
		})
	end
end


---@param entity entity.transform
---@param rotation number In degrees
function M:set_rotation(entity, rotation)
	local t = entity.transform
	local is_changed = t.rotation ~= rotation
	t.rotation = rotation or t.rotation

	if is_changed then
		self.world.event_bus:trigger("transform_event", {
			entity = entity,
			is_rotation_changed = true,
		})
	end
end


---@param entity entity.transform
---@param animate_time number|nil
---@param easing userdata|nil
function M:set_animate_time(entity, animate_time, easing)
	self.world.event_bus:trigger("transform_event", {
		entity = entity,
		animate_time = animate_time,
		easing = easing,
	})
end


---@param events system.transform.event[]
---@param event system.transform.event
---@return boolean is_merged
function M.event_merge_policy(event, events)
	local entity = event.entity
	for i = 1, #events do
		local e = events[i]
		if e.entity == entity then
			e.is_position_changed = event.is_position_changed or e.is_position_changed
			e.is_scale_changed = event.is_scale_changed or e.is_scale_changed
			e.is_rotation_changed = event.is_rotation_changed or e.is_rotation_changed
			e.is_size_changed = event.is_size_changed or e.is_size_changed
			e.animate_time = event.animate_time or e.animate_time
			e.easing = event.easing or e.easing
			return true
		end
	end

	return false
end


return M
