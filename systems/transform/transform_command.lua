local ecs = require("decore.ecs")

---@class entity
---@field transform_command component.transform_command|nil

---@class entity.transform_command: entity
---@field transform_command component.transform_command

---@class component.transform_command
---@field entity entity @The entity to apply the transform to.
---@field position_x number|nil @Position x in pixels.
---@field position_y number|nil @Position y in pixels.
---@field position_z number|nil @Position z in pixels.
---@field scale_x number|nil @Scale x in pixels.
---@field scale_y number|nil @Scale y in pixels.
---@field scale_z number|nil @Scale z in pixels.
---@field size_x number|nil @Size x in pixels.
---@field size_y number|nil @Size y in pixels.
---@field size_z number|nil @Size z in pixels.
---@field rotation number|nil @Rotation around x axis in degrees.
---@field animate_time number|nil @If true will animate the transform over time.
---@field easing userdata|nil @The easing function to use for the animation.
---@field relative boolean|nil @If true, the values are relative to the current values.

---@class system.transform_command: system
---@field entities entity.transform_command[]
---@field transform system.transform
local M = {}


---@static
---@return system.transform_command
function M.create_system(transform)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("transform_command")
	system.transform = transform
	system.id = "transform_command"

	return system
end


---@param entity entity.transform_command
function M:onAdd(entity)
	local command = entity.transform_command
	if command then
		self:process_command(command)
		self.world:removeEntity(entity)
	end
end


---@param command component.transform_command
function M:process_command(command)
	local entity = command.entity --[[@as entity.transform]]
	local t = entity.transform

	local is_position_changed = command.position_x ~= nil or command.position_y ~= nil or command.position_z ~= nil
	t.position_x = command.position_x or t.position_x
	t.position_y = command.position_y or t.position_y
	t.position_z = command.position_z or t.position_z

	local is_scale_changed = command.scale_x ~= nil or command.scale_y ~= nil or command.scale_z ~= nil
	t.scale_x = command.scale_x or t.scale_x
	t.scale_y = command.scale_y or t.scale_y
	t.scale_z = command.scale_z or t.scale_z

	local is_size_changed = command.size_x ~= nil or command.size_y ~= nil or command.size_z ~= nil
	t.size_x = command.size_x or t.size_x
	t.size_y = command.size_y or t.size_y
	t.size_z = command.size_z or t.size_z

	local is_rotation_changed = command.rotation ~= nil
	t.rotation = command.rotation or t.rotation

	local is_any_changed = is_position_changed or is_scale_changed or is_rotation_changed or is_size_changed

	if is_any_changed then
		---@type entity.transform_event
		local transform_event = { transform_event = {
			entity = entity,
			is_position_changed = is_position_changed,
			is_scale_changed = is_scale_changed,
			is_size_changed = is_size_changed,
			is_rotation_changed = is_rotation_changed,
			animate_time = command.animate_time,
			easing = command.easing
		}}

		self.world:addEntity(transform_event)
	end
end


return M
