local ecs = require("decore.ecs")

---@class entity
---@field TEMPLATE_event component.TEMPLATE_event|nil

---@class entity.TEMPLATE_event: entity
---@field TEMPLATE_event component.TEMPLATE_event

---@class component.TEMPLATE_event
---@field entity entity|nil

---@class system.TEMPLATE_event: system
---@field entities entity.TEMPLATE_event[]
local M = {}


---@static
---@return system.TEMPLATE_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("TEMPLATE_event")
	system.id = "TEMPLATE_event"

	return system
end


function M:postWrap()
	for index = #self.entities, 1, -1 do
		self.world:removeEntity(self.entities[index])
	end
end


return M
