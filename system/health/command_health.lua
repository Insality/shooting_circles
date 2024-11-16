---@class world
---@field command_health command.health

---@class command.health
---@field health system.health
local M = {}


---@return command.health
function M.create(health)
	return setmetatable({ health = health }, { __index = M })
end


---@param entity entity.health
---@param damage number
function M:apply_damage(entity, damage)
	assert(entity.health, "Entity does not have a health component.")
	self.health:apply_damage(entity, damage)
end


return M
