local ecs = require("decore.ecs")

---@class entity
---@field collision_event component.collision_event|nil

---@class entity.collision_event: entity
---@field collision_event component.collision_event

---@class component.collision_event
---@field entity entity
---@field other entity
---@field trigger_event physics.collision.trigger_event|nil
---@field collision_event physics.collision.collision_event|nil

---@class component.collider_event.trigger

---@class component.collider_event.collision

---@class system.collision_event: system
---@field entities entity.collision_event[]
local M = {}


---@static
---@return system.collision_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("collision_event")

	return system
end


function M:postWrap()
	for index = #self.entities, 1, -1 do
		self.world:removeEntity(self.entities[index])
	end
end


return M
