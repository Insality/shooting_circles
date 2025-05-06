local decore = require("decore.decore")

---@class entity
---@field remove_with_delay number|nil

---@class entity.remove_with_delay: entity
---@field remove_with_delay number

---@class component.remove_with_delay
decore.register_component("remove_with_delay", 0)

---@class system.remove_with_delay: system
---@field entities entity.remove_with_delay[]
local M = {}


---@return system.remove_with_delay
function M.create_system()
	return decore.processing_system(M, "remove_with_delay", "remove_with_delay")
end


---@param entity entity.remove_with_delay
---@param dt number
function M:process(entity, dt)
	entity.remove_with_delay = entity.remove_with_delay - dt
	if entity.remove_with_delay <= 0 then
		self.world:removeEntity(entity)
	end
end


return M
