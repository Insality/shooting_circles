local decore = require("decore.decore")

---@class system.on_key_released_command: system
---@field on_key_released system.on_key_released
local M = {}


---@static
---@return system.on_key_released_command
function M.create_system(on_key_released)
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.id = "on_key_released_command"
	system.on_key_released = on_key_released

	return system
end


function M:postWrap()
	self.world.queue:process("input_event", self.process_input_event, self)
end


---@param input_event event.input_event
function M:process_input_event(input_event)
	local entities = self.on_key_released.entities
	for index = 1, #entities do
		local entity = entities[index]
		self.on_key_released:apply_input(entity, input_event.action_id, input_event)
	end
end


return M
