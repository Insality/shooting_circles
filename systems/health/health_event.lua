local ecs = require("decore.ecs")

---@class entity
---@field health_event component.health_event|nil

---@class entity.health_event: entity
---@field health_event component.health_event

---@class component.health_event
---@field entity entity
---@field damage number

---@class system.health_event: system
---@field entities entity.health_event[]
local M = {}


---@static
---@return system.health_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("health_event")

	return system
end


function M:postWrap()
	for index = #self.entities, 1, -1 do
		self.world:removeEntity(self.entities[index])
	end
end


return M
