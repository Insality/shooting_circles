local ecs = require("decore.ecs")

local health_command = require("systems.health.health_command")
local health_event = require("systems.health.health_event")

---@class entity
---@field health component.health|nil

---@class entity.health: entity
---@field health component.health

---@class component.health
---@field health number
---@field current_health number|nil

---@class system.health: system
---@field entities entity.health[]
local M = {}


---@static
---@return system.health, system.health_command, system.health_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("health")

	return system, health_command.create_system(system), health_event.create_system()
end


---@param entity entity.health
function M:onAdd(entity)
	local health = entity.health
	health.current_health = health.health
end


---@param entity entity.health
function M:apply_damage(entity, damage)
	local health = entity.health
	if health then
		health.current_health = math.max(0, health.current_health - damage)

		---@type component.health_event
		local event = {
			entity = entity,
			damage = damage,
		}
		self.world:addEntity({ health_event = event })
	end
end


return M
