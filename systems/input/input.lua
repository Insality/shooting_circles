local ecs = require("decore.ecs")

local system_input_event = require("systems.input.input_event")

---@class system.input: system
---@field entities entity[]
local M = {}


---@static
---@return system.input, system.input_event
function M.create_system()
	local system = setmetatable(ecs.processingSystem(), { __index = M })
	system.id = "input"

	return system, system_input_event.create_system()
end


function M:onAddToWorld()
	msg.post(".", "acquire_input_focus")
end


function M:onRemoveFromWorld()
	msg.post(".", "release_input_focus")
end


return M
