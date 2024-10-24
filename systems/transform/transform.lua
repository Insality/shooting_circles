local decore = require("decore.decore")

local transform_command = require("systems.transform.transform_command")

---@class entity
---@field transform component.transform|nil

---@class entity.transform: entity
---@field transform component.transform

---@class entity.transform_command: entity
---@field transform component.transform

---@class component.transform
---@field position_x number
---@field position_y number
---@field position_z number
---@field size_x number
---@field size_y number
---@field scale_x number
---@field scale_y number
---@field rotation number
decore.register_component("transform", {
	position_x = 0,
	position_y = 0,
	position_z = 0,
	size_x = 1,
	size_y = 1,
	scale_x = 1,
	scale_y = 1,
	rotation = 0,
})

---@class event.transform_event
---@field entity entity @The entity that was changed.
---@field is_position_changed boolean|nil @If true, the position was changed.
---@field is_scale_changed boolean|nil @If true, the scale was changed.
---@field is_rotation_changed boolean|nil @If true, the rotation was changed.
---@field is_size_changed boolean|nil @If true, the size was changed.
---@field animate_time number|nil @If true, the time it took to animate the transform.
---@field easing userdata|nil @The easing function used for the animation.

---@class system.transform: system
---@field entities entity.transform[]
local M = {}


---@static
---@return system.transform, system.transform_command
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("transform")
	system.id = "transform"

	return system, transform_command.create_system(system)
end


function M:onAddToWorld()
	self.world.queue:set_merge_policy("transform_event", self.event_merge_policy)
end


---@static
---Return node borders relative to the current node parent
---@param entity entity
---@return number, number, number, number @left, right, top, bottom
function M.get_transform_borders(entity)
	local t = entity.transform --[[@as component.transform]]

	local left = t.position_x - t.size_x * 0.5
	local right = t.position_x + t.size_x * 0.5
	local top = t.position_y + t.size_y * 0.5
	local bottom = t.position_y - t.size_y * 0.5

	return left, right, top, bottom
end


---@static
---Check if two entities are overlapping
---@param entity1 entity
---@param entity2 entity
---@return boolean
function M.is_overlap(entity1, entity2)
	local left1, right1, top1, bottom1 = M.get_transform_borders(entity1)
	local left2, right2, top2, bottom2 = M.get_transform_borders(entity2)

	return left1 < right2 and right1 > left2 and top1 > bottom2 and bottom1 < top2
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
