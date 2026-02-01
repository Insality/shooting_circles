local decore = require("decore.decore")
local input_command = require("system.input.input_command")

---@class system.input.event: action

---@class system.input: system
local M = {}


---@return system.input
function M.create()
	return decore.system(M, "input")
end


---@protected
function M:onAddToWorld()
	msg.post(".", "acquire_input_focus")
	self.world.input = input_command.create(self)
end


return M
