local ecs = require("decore.ecs")

---@class entity
---@field shooter_controller_command component.shooter_controller_command|nil

---@class entity.shooter_controller_command: entity
---@field shooter_controller_command component.shooter_controller_command

---@class component.shooter_controller_command
---@field entity entity|nil

---@class system.shooter_controller_command: system
---@field entities entity.shooter_controller_command[]
---@field shooter_controller system.shooter_controller
local M = {}

local HASH_TOUCH = hash("touch")
local HASH_SPACE = hash("key_space")


---@static
---@return system.shooter_controller_command
function M.create_system(shooter_controller)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("input_event")
	system.shooter_controller = shooter_controller

	return system
end


---@param entity entity.shooter_controller_command
function M:onAdd(entity)
	local command = entity.shooter_controller_command
	if command then
		self:process_command(command)
		self.world:removeEntity(entity)
	end

	local input_event = entity.input_event
	if input_event then
		for _, e in ipairs(self.shooter_controller.entities) do
			self:process_input_event(e, input_event)
		end
	end
end


---@param command component.shooter_controller_command
function M:process_command(command)
	local entity = command.entity
end


---@param entity entity.shooter_controller
---@param input_event component.input_event
function M:process_input_event(entity, input_event)
	local action_id = input_event.action_id
	local action = input_event.action
	local sc = entity.shooter_controller

	if action.screen_x and action.screen_y then
		sc.last_screen_x = action.screen_x
		sc.last_screen_y = action.screen_y
	end

	if action_id == HASH_TOUCH or action_id == HASH_SPACE then
		if action.pressed then
			sc.burst_count_current = 0
			self.shooter_controller:shoot_at(entity, sc.last_screen_x, sc.last_screen_y)
		else
			if sc.is_auto_shoot then
				if sc.fire_rate_timer == 0 then
					self.shooter_controller:shoot_at(entity, sc.last_screen_x, sc.last_screen_y)
				end
			end
		end
	end
end


return M
