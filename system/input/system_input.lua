local decore = require("decore.decore")
local command_input = require("system.input.command_input")

---@class system.input.event: action

---@class system.input: system
---@field entities entity[]
local M = {}


---@return system.input
function M.create_system()
	return decore.system(M, "input")
end


function M:onAddToWorld()
	msg.post(".", "acquire_input_focus")
	self.world.command_input = command_input.create(self)
end


function M:onRemoveFromWorld()
	msg.post(".", "release_input_focus")
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
