local decore = require("decore.decore")

---@class entity
---@field target_tracker component.target_tracker|nil

---@class entity.target_tracker: entity
---@field target_tracker component.target_tracker

---@class component.target_tracker

---@class event.target_tracker_event: number

---@class system.target_tracker: system
---@field entities entity.target_tracker[]
local M = {}


---@static
---@return system.target_tracker
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("target")

	return system
end


---@param entity entity.target_tracker
function M:onAdd(entity)
	decore.queue:push("target_tracker_event", #self.entities)
end


---@param entity entity.target_tracker
function M:onRemove(entity)
	decore.queue:push("target_tracker_event", #self.entities)
end


return M
