local ecs = require("decore.ecs")

---@class system.on_key_released_command: system
---@field on_key_released system.on_key_released
local M = {}


---@static
---@return system.on_key_released_command
function M.create_system(on_key_released)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("input_event")
	system.id = "on_key_released_command"
	system.on_key_released = on_key_released

	return system
end


---@param entity entity
function M:onAdd(entity)
	local input_event = entity.input_event
	if input_event then
		self:process_input_event(input_event)
	end
end


---@param input_event component.input_event
function M:process_input_event(input_event)
	local entities = self.on_key_released.entities
	for index = 1, #entities do
		local entity = entities[index]
		self.on_key_released:apply_input(entity, input_event.action_id, input_event.action)
	end
end


return M
