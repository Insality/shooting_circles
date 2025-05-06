---@class world
---@field command_input system.input.command

---@class system.input.command
---@field input system.input
local M = {}


---@return system.input.command
function M.create(input)
	return setmetatable({ input = input }, { __index = M })
end


---@param action_id hash
---@param action action
---@return boolean
function M:on_input(action_id, action)
	return self.input:on_input(action_id, action)
end


return M
