local decore = require("decore.decore")
local command_health = require("system.health.command_health")

---@class entity
---@field health component.health|nil

---@class entity.health: entity
---@field health component.health

---@class component.health
---@field max_health number
---@field current_health number|nil
---@field remove_on_death boolean|nil
decore.register_component("health", {
	max_health = 1,
})

---@class system.health.event
---@field entity entity
---@field damage number

---@class system.health: system
---@field entities entity.health[]
local M = {}


---@return system.health
function M.create_system()
	return decore.system(M, "health", "health")
end


function M:onAddToWorld()
	self.world.command_health = command_health.create(self)
	self.world.event_bus:set_merge_policy("health_event", M.event_merge_policy)
end


---@param entity entity.health
function M:onAdd(entity)
	local health = entity.health
	health.current_health = health.max_health
end


---@param entity entity.health
function M:apply_damage(entity, damage)
	local health = entity.health
	health.current_health = math.max(0, health.current_health - damage)
	self.world.event_bus:trigger("health_event", {
		entity = entity,
		damage = damage,
	})

	if health.current_health == 0 and health.remove_on_death then
		self.world:removeEntity(entity)
	end
end


---@param event system.health.event
---@param events system.health.event[]
---@return boolean
function M.event_merge_policy(event, events)
	for index = #events, 1, -1 do
		local compare_event = events[index]
		if compare_event.entity == event.entity then
			compare_event.damage = compare_event.damage + event.damage
			return true
		end
	end

	return false
end


return M
