local ecs = require("decore.ecs")

---@class entity
---@field remove_with_delay component.remove_with_delay|nil

---@class entity.remove_with_delay: entity
---@field remove_with_delay component.remove_with_delay

---@class component.remove_with_delay
---@field delay number

---@class system.remove_with_delay: system
---@field entities entity.remove_with_delay[]
local M = {}


---@static
---@return system.remove_with_delay
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("remove_with_delay")

	return system
end


---@param entity entity.remove_with_delay
function M:onAdd(entity)
	timer.delay(entity.remove_with_delay.delay, false, function()
		self.world:removeEntity(entity)
	end)
end


return M
