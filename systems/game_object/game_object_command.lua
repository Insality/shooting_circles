local decore = require("decore.decore")

---@class system.game_object_command: system
---@field game_object system.game_object
local M = {}

local TEMP_VECTOR = vmath.vector3()

---@static
---@return system.game_object_command
function M.create_system(game_object)
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.id = "game_object_command"
	system.game_object = game_object

	return system
end


function M:postWrap()
	self.world.queue:process("transform_event", self.process_transform_event, self)
end


---@param transform_event event.transform_event
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
