---@class world
---@field command_health system.health.command

---@class system.health.command
---@field health system.health
local M = {}


---@param health system.health
---@return system.health.command
function M.create(health)
	return setmetatable({ health = health }, { __index = M })
end


---@param entity entity
---@param damage number
function M:apply_damage(entity, damage)
	assert(entity.health, "Entity does not have a health component.")
	---@cast entity entity.health
	self.health:apply_damage(entity, damage)
end


return M
