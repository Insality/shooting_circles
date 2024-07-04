local ecs = require("decore.ecs")

---@class entity
---@field target_tracker_event component.target_tracker_event|nil

---@class entity.target_tracker_event: entity
---@field target_tracker_event component.target_tracker_event

---@class component.target_tracker_event
---@field target_count number

---@class system.target_tracker_event: system
---@field entities entity.target_tracker_event[]
local M = {}


---@static
---@return system.target_tracker_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("target_tracker_event")

	return system
end


function M:postWrap()
	for index = #self.entities, 1, -1 do
		self.world:removeEntity(self.entities[index])
	end
end


return M
