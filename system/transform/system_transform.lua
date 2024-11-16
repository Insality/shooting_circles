local decore = require("decore.decore")
local command_transform = require("system.transform.command_transform")

---@class entity
---@field transform component.transform|nil

---@class entity.transform: entity
---@field transform component.transform

---@class entity.command_transform: entity
---@field transform component.transform

---@class component.transform
---@field position_x number
---@field position_y number
---@field position_z number
---@field size_x number
---@field size_y number
---@field size_z number
---@field scale_x number
---@field scale_y number
---@field scale_z number
---@field rotation number
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

---@class event.transform_event
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
	entity.transform.position_x = x or entity.transform.position_x
	entity.transform.position_y = y or entity.transform.position_y
	entity.transform.position_z = z or entity.transform.position_z

	self.world.event_bus:trigger("transform_event", {
		entity = entity,
		is_position_changed = true
	})
end


---@param entity entity.transform
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_scale(entity, x, y, z)
	entity.transform.scale_x = x or entity.transform.scale_x
	entity.transform.scale_y = y or entity.transform.scale_y
	entity.transform.scale_z = z or entity.transform.scale_z

	self.world.event_bus:trigger("transform_event", {
		entity = entity,
		is_scale_changed = true
	})
end


---@param entity entity.transform
---@param x number|nil
---@param y number|nil
---@param z number|nil
function M:set_size(entity, x, y, z)
	entity.transform.size_x = x or entity.transform.size_x
	entity.transform.size_y = y or entity.transform.size_y
	entity.transform.size_z = z or entity.transform.size_z

	self.world.event_bus:trigger("transform_event", {
		entity = entity,
		is_size_changed = true
	})
end


function M:set_rotation(entity, rotation)
	entity.transform.rotation = rotation

	self.world.event_bus:trigger("transform_event", {
		entity = entity,
		is_rotation_changed = true
	})
end


---@param entity entity.transform
---@param animate_time number|nil
---@param easing userdata|nil
function M:set_animate_time(entity, animate_time, easing)
	self.world.event_bus:trigger("transform_event", {
		entity = entity,
		animate_time = animate_time,
		easing = easing
	})
end


---@param events event.transform_event[]
---@param event event.transform_event
function M.event_merge_policy(events, event)
	for index = #events, 1, -1 do
		local compare_event = events[index]
		if compare_event.entity == event.entity then
			compare_event.is_position_changed = compare_event.is_position_changed or event.is_position_changed
			compare_event.is_scale_changed = compare_event.is_scale_changed or event.is_scale_changed
			compare_event.is_rotation_changed = compare_event.is_rotation_changed or event.is_rotation_changed
			compare_event.is_size_changed = compare_event.is_size_changed or event.is_size_changed
			compare_event.animate_time = event.animate_time or compare_event.animate_time
			compare_event.easing = event.easing or compare_event.easing

			return true
		end
	end

	return false
end


return M
