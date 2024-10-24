local ecs = require("decore.ecs")

---@class entity
---@field on_collision_damage component.on_collision_damage|nil

---@class entity.on_collision_damage: entity
---@field on_collision_damage component.on_collision_damage

---@class component.on_collision_damage
---@field damage number

---@class system.on_collision_damage: system
---@field entities entity.on_collision_damage[]
local M = {}


---@static
---@return system.on_collision_damage
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("collision_event")

	return system
end


---@param entity entity.on_collision_damage
function M:onAdd(entity)
	local collision_event = entity.collision_event
	if collision_event then
		self:process_collision_event(collision_event)
		self.world:removeEntity(entity)
	end
end


---@param collision_event component.collision_event
function M:process_collision_event(collision_event)
	local entity = collision_event.entity
	local on_collision_damage = entity.on_collision_damage
	local other = collision_event.other
	if on_collision_damage and other and other.health then
		---@type component.health_command
		local command = {
			entity = other,
			damage = on_collision_damage.damage
		}
		self.world:addEntity({ health_command = command })
	end
end


return M
