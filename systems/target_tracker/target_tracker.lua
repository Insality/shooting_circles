local decore = require("decore.decore")

---@class entity
---@field target boolean|nil

---@class entity.target: entity
---@field target boolean
decore.register_component("target")

---@class event.target_tracker_event: number

---@class system.target_tracker: system
---@field entities entity.target[]
local M = {}


---@static
---@return system.target_tracker
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("target")
	system.id = "target_tracker"

	return system
end


function M:onAdd()
	self.world.queue:push("target_tracker_event", #self.entities)
end


function M:onRemove()
	self.world.queue:push("target_tracker_event", #self.entities)
end


return M
