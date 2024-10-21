local ecs = require("decore.ecs")

local explosion_command = require("systems.explosion.explosion_command")

---@class entity
---@field explosion component.explosion|nil

---@class entity.explosion: entity
---@field explosion component.explosion

---@class component.explosion
---@field power number
---@field distance number

---@class system.explosion: system
---@field entities entity.explosion[]
local M = {}


---@static
---@return system.explosion, system.explosion_command
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("physics", "transform")

	return system, explosion_command.create_system(system)
end


function M:apply_explosion(entity, position_x, position_y, power)
	local target_x = entity.transform.position_x
	local target_y = entity.transform.position_y
	local force_x = target_x - position_x
	local force_y = target_y - position_y
	local distance = math.sqrt(force_x * force_x + force_y * force_y)
	force_x = force_x / distance * power
	force_y = force_y / distance * power

	self.world.physics_command:add_force(entity, force_x, force_y)
end


return M
