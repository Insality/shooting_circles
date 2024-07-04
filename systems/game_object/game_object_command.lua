local ecs = require("decore.ecs")

---@class entity
---@field game_object_command component.game_object_command|nil

---@class entity.game_object_command: entity
---@field game_object_command component.game_object_command

---@class component.game_object_command
---@field entity entity|nil
---@field enabled boolean|nil

---@class system.game_object_command: system
---@field entities entity.game_object_command[]
---@field game_object system.game_object
local M = {}

local TEMP_VECTOR = vmath.vector3()

---@static
---@return system.game_object_command
function M.create_system(game_object)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("game_object_command", "transform_event")
	system.id = "game_object_command"
	system.game_object = game_object

	return system
end


---@param entity entity.game_object_command|entity.transform_event
function M:onAdd(entity)
	local command = entity.game_object_command
	if command then
		self:process_command(command)
	end

	local transform_event = entity.transform_event
	if transform_event and self.game_object.indices[transform_event.entity] then
		self:process_transform_event(transform_event)
	end

	self.world:removeEntity(entity)
end


---@param command component.game_object_command
function M:process_command(command)
	local entity = command.entity
	if not entity then
		return
	end

	if command.enabled ~= nil then
		for _, game_object in pairs(entity.game_object.object) do
			if command.enabled then
				msg.post(game_object, "enable")
			else
				msg.post(game_object, "disable")
			end
		end
	end
end


---@param transform_event component.transform_event
function M:process_transform_event(transform_event)
	local target_entity = transform_event.entity
	local game_object = target_entity.game_object
	if not game_object or target_entity.physics then
		return
	end

	local root = target_entity.game_object.root
	if root and transform_event.is_position_changed then
		TEMP_VECTOR.x = target_entity.transform.position_x
		TEMP_VECTOR.y = target_entity.transform.position_y
		TEMP_VECTOR.z = target_entity.transform.position_z

		local animate_time = transform_event.animate_time
		if animate_time then
			local easing = transform_event.easing or go.EASING_LINEAR
			go.animate(target_entity.game_object.root, "position", go.PLAYBACK_ONCE_FORWARD, TEMP_VECTOR, easing, animate_time)
		else
			go.set_position(TEMP_VECTOR, root)
		end
	end
end


return M
