local ecs = require("decore.ecs")

---@class world
---@field health_command system.health_command

---@class system.health_command: system_command
---@field health system.health
local M = {}


---@static
---@return system.health_command
function M.create_system(health)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("health_command")
	system.health = health

	return system
end


---@private
function M:onAddToWorld()
	self.world.health_command = self
end


---@private
function M:onRemoveFromWorld()
	self.world.health_command = nil
end


---@param entity entity
---@param damage number
function M:apply_damage(entity, damage)
	assert(entity.health, "Entity does not have a health_command component.")
	---@cast entity entity.health

	self.health:apply_damage(entity, damage)
end


return M
