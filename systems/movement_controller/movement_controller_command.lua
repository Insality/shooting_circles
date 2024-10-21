local decore = require("decore.decore")

---@class entity
---@field movement_controller_command component.movement_controller_command|nil

---@class entity.movement_controller_command: entity
---@field movement_controller_command component.movement_controller_command

---@class component.movement_controller_command
---@field entity entity|nil

---@class system.movement_controller_command: system
---@field entities entity.movement_controller_command[]
---@field movement_controller system.movement_controller
local M = {}


local ACTION_ID_TO_SIDE = {
	[hash("key_w")] = { y = 1 },
	[hash("key_s")] = { y = -1 },
	[hash("key_a")] = { x = -1 },
	[hash("key_d")] = { x = 1 },
	[hash("key_up")] = { y = 1 },
	[hash("key_down")] = { y = -1 },
	[hash("key_left")] = { x = -1 },
	[hash("key_right")] = { x = 1 },
}


---@static
---@return system.movement_controller_command
function M.create_system(movement_controller)
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.movement_controller = movement_controller

	return system
end


function M:postWrap()
	self.world.queue:process("input_event", self.process_input_event, self)
end


---@param input_event event.input_event
function M:process_input_event(input_event)
	local action_id = input_event.action_id
	local side = ACTION_ID_TO_SIDE[action_id]
	if side then
		for _, e in ipairs(self.movement_controller.entities) do
			self:apply_input_event(e, input_event)
		end
	end
end


---@param entity entity.movement_controller
---@param input_event event.input_event
function M:apply_input_event(entity, input_event)
	local action_id = input_event.action_id
	local action = input_event
	local movement_controller = entity.movement_controller

	local side = ACTION_ID_TO_SIDE[action_id]
	if action.pressed then
		if side.x then
			movement_controller.movement_x = side.x
		end
		if side.y then
			movement_controller.movement_y = side.y
		end
	end
	if action.released then
		if side.x then
			movement_controller.movement_x = 0
		end
		if side.y then
			movement_controller.movement_y = 0
		end
	end
end


return M
