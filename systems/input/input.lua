local ecs = require("decore.ecs")

---@class event.input_event: action

---@class system.input: system
---@field entities entity[]
local M = {}


---@static
---@return system.input
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.id = "input"

	return system
end


function M:onAddToWorld()
	msg.post(".", "acquire_input_focus")
end


function M:onRemoveFromWorld()
	msg.post(".", "release_input_focus")
end


return M
