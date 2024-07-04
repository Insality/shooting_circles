local ecs = require("decore.ecs")

local target_tracker_event = require("systems.target_tracker.target_tracker_event")

---@class entity
---@field target_tracker component.target_tracker|nil

---@class entity.target_tracker: entity
---@field target_tracker component.target_tracker

---@class component.target_tracker

---@class system.target_tracker: system
---@field entities entity.target_tracker[]
local M = {}


---@static
---@return system.target_tracker, system.target_tracker_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("target")

	return system, target_tracker_event.create_system()
end


---@param entity entity.target_tracker
function M:onAdd(entity)
	---@type component.target_tracker_event
	local target_tracker_event = {
		target_count = #self.entities,
	}
	self.world:addEntity({ target_tracker_event = target_tracker_event })
end


---@param entity entity.target_tracker
function M:onRemove(entity)
	---@type component.target_tracker_event
	local target_tracker_event = {
		target_count = #self.entities,
	}
	self.world:addEntity({ target_tracker_event = target_tracker_event })
end


return M
