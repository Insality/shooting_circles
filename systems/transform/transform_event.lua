local ecs = require("decore.ecs")

---@class entity
---@field transform_event component.transform_event|nil

---@class entity.transform_event: entity
---@field transform_event component.transform_event

---@class component.transform_event
---@field entity entity @The entity that was changed.
---@field is_position_changed boolean|nil @If true, the position was changed.
---@field is_scale_changed boolean|nil @If true, the scale was changed.
---@field is_rotation_changed boolean|nil @If true, the rotation was changed.
---@field is_size_changed boolean|nil @If true, the size was changed.
---@field animate_time number|nil @If true, the time it took to animate the transform.
---@field easing userdata|nil @The easing function used for the animation.

---@class system.transform_event: system
---@field entities entity.transform_event[]
local M = {}


---@static
---@return system.transform_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("transform_event")
	system.id = "transform_event"

	return system
end


function M:postWrap()
	for index = #self.entities, 1, -1 do
		self.world:removeEntity(self.entities[index])
	end
end


return M
