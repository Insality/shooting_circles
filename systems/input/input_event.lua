local ecs = require("decore.ecs")

---@class entity
---@field input_event component.input_event|nil

---@class entity.input_event: entity
---@field input_event component.input_event

---@class component.input_event
---@field action_id hash|nil
---@field action action

---@class system.input_event: system
---@field entities entity.input_event[]
local M = {}


---@static
---@return system.input_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("input_event")
	system.id = "input_event"

	return system
end


function M:postWrap()
	for index = #self.entities, 1, -1 do
		self.world:removeEntity(self.entities[index])
	end
end


return M
