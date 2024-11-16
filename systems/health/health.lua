local decore = require("decore.decore")

local health_command = require("systems.health.health_command")

---@class entity
---@field health component.health|nil

---@class entity.health: entity
---@field health component.health

---@class component.health
---@field health number
---@field current_health number|nil
decore.register_component("health", {
	health = 0,
})

---@class event.health_event
---@field entity entity
---@field damage number

---@class system.health: system
---@field entities entity.health[]
local M = {}


---@static
---@return system.health, system.health_command
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("health")

	return system, health_command.create_system(system)
end


function M:onAddToWorld()
	self.world.event_bus:set_merge_policy("health_event", function(events, event)
		---@cast events event.health_event[]
		---@cast event event.health_event

		for index = #events, 1, -1 do
			local compare_event = events[index]
			if compare_event.entity == event.entity then
				compare_event.damage = compare_event.damage + event.damage
				return true
			end
		end

		return false
	end)
end


---@param entity entity.health
function M:onAdd(entity)
	local health = entity.health
	health.current_health = health.health
end


---@param entity entity.health
function M:apply_damage(entity, damage)
	local health = entity.health
	health.current_health = math.max(0, health.current_health - damage)
	self.world.event_bus:trigger("health_event", { entity = entity, damage = damage })
end


return M
