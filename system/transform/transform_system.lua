local decore = require("decore.decore")
local transform_command = require("system.transform.transform_command")

---@class entity
---@field transform component.transform?

---@class entity.transform: entity
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
---@field is_animated boolean Whether the transform is animated
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
---@field delay number|nil The delay before the animation starts.
---@field callback function|nil The callback function to call when the animation is complete.

---@class system.transform: system
---@field entities entity.transform[]
local M = {}


---@return system.transform
function M.create()
	return decore.system(M, "transform", "transform")
end


function M:onAddToWorld()
	self.world.transform = transform_command.create(self)
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
---@param delay number|nil
---@param callback function|nil
function M:set_animate_time(entity, animate_time, easing, delay, callback)
	self.world.event_bus:trigger("transform_event", {
		entity = entity,
		animate_time = animate_time,
		easing = easing,
		delay = delay,
		callback = callback
	})
end


---@param new_event system.transform.event
---@param events system.transform.event[]
---@param entity_map table<entity|table, system.transform.event[]>
---@return boolean is_merged
function M.event_merge_policy(new_event, events, entity_map)
	local entity = new_event.entity
	if not entity then
		return false
	end

	local existing_events = entity_map[entity]
	if existing_events and #existing_events > 0 then
		-- Merge with the last event for this entity
		local existing_event = existing_events[#existing_events]
		existing_event.is_position_changed = new_event.is_position_changed or existing_event.is_position_changed
		existing_event.is_scale_changed = new_event.is_scale_changed or existing_event.is_scale_changed
		existing_event.is_rotation_changed = new_event.is_rotation_changed or existing_event.is_rotation_changed
		existing_event.is_size_changed = new_event.is_size_changed or existing_event.is_size_changed
		existing_event.animate_time = new_event.animate_time or existing_event.animate_time
		existing_event.easing = new_event.easing or existing_event.easing
		existing_event.delay = new_event.delay or existing_event.delay
		existing_event.callback = new_event.callback or existing_event.callback
		return true
	end

	return false
end


return M
