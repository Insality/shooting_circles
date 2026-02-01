---@class world
---@field input system.input.command

---@class action
---@field action_id hash

---@class system.input.command
---@field private input system.input
---@field private world world
local M = {}


---@return system.input.command
function M.create(input)
	return setmetatable({ input = input, world = input.world }, { __index = M })
end


---@param action_id hash
---@param action action
---@return boolean
function M:on_input(action_id, action)
	action.action_id = action_id
	self.world.event_bus:trigger("input_event", action)
	return false
end


return M
