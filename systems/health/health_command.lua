local ecs = require("decore.ecs")

---@class entity
---@field health_command component.health_command|nil

---@class entity.health_command: entity
---@field health_command component.health_command

---@class component.health_command
---@field entity entity
---@field damage number|nil

---@class system.health_command: system
---@field entities entity.health_command[]
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


---@param entity entity.health_command
function M:onAdd(entity)
	local command = entity.health_command
	if command then
		self:process_command(command)
		self.world:removeEntity(entity)
	end
end


---@param command component.health_command
function M:process_command(command)
	if command.damage then
		self.health:apply_damage(command.entity, command.damage)
	end
end


return M
