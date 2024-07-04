local ecs = require("decore.ecs")

---@class entity
---@field color_event component.color_event|nil

---@class entity.color_event: entity
---@field color_event component.color_event

---@class component.color_event
---@field entity entity
---@field color vector4

---@class system.color_event: system
---@field entities entity.color_event[]
local M = {}


---@static
---@return system.color_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("color_event")
	system.id = "color_event"

	return system
end


function M:postWrap()
	for index = #self.entities, 1, -1 do
		self.world:removeEntity(self.entities[index])
	end
end


return M
