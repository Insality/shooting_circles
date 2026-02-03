local decore = require("decore.decore")

---@class entity
---@field target boolean|nil

---@class entity.target: entity
---@field target boolean
decore.register_component("target", false)

---@class event.target_tracker_event: number

---@class system.target_tracker: system
---@field entities entity.target[]
local M = {}


---@static
---@return system.target_tracker
function M.create()
	return decore.system(M, "target_tracker", "target")
end


function M:onAdd()
	self.world.event_bus:trigger("target_tracker_event", #self.entities)
end


function M:onRemove()
	self.world.event_bus:trigger("target_tracker_event", #self.entities)
end


return M
