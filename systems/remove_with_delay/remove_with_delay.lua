local decore = require("decore.decore")

---@class entity
---@field remove_with_delay component.remove_with_delay|nil

---@class entity.remove_with_delay: entity
---@field remove_with_delay component.remove_with_delay

---@class component.remove_with_delay
---@field delay number
---@field timer_id hash|nil

---@class system.remove_with_delay: system
---@field entities entity.remove_with_delay[]
local M = {}


---@static
---@return system.remove_with_delay
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("remove_with_delay")

	return system
end


---@param entity entity.remove_with_delay
function M:onAdd(entity)
	entity.remove_with_delay.timer_id = timer.delay(entity.remove_with_delay.delay, false, function()
		entity.remove_with_delay.timer_id = nil
		self.world:removeEntity(entity)
	end)
end


function M:onRemove(entity)
	if entity.remove_with_delay.timer_id then
		timer.cancel(entity.remove_with_delay.timer_id)
		entity.remove_with_delay.timer_id = nil
	end
end


return M
