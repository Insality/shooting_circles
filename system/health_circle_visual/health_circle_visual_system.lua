local decore = require("decore.decore")
local panthera = require("panthera.panthera")

---@class entity
---@field health_circle_visual component.health_circle_visual|nil

---@class entity.health_circle_visual: entity
---@field health_circle_visual component.health_circle_visual
---@field health component.health

---@class component.health_circle_visual
---@field on_damage_animation panthera.animation
decore.register_component("health_circle_visual", {})

---@class system.health_circle_visual: system
---@field entities entity.health_circle_visual[]
local M = {}


---@static
---@return system.health_circle_visual
function M.create()
	return decore.system(M, "health_circle_visual", { "health_circle_visual", "health" })
end


function M:postWrap()
	self.world.event_bus:process("health_event", self.process_health_events, self)
end


---@param entity entity.health_circle_visual
function M:onAdd(entity)
	entity.health_circle_visual.on_damage_animation = panthera.clone_state(entity.panthera.animation_state)
end


---@param health_events system.health.event[]
function M:process_health_events(health_events)
	for _, health_event in ipairs(health_events) do
		local entity = health_event.entity

		if entity.health_circle_visual and health_event.damage then
			local progress = entity.health.current_health / entity.health.max_health
			self.world.panthera:set_progress(entity, "health", progress)
			self.world.panthera:play_state(entity, entity.health_circle_visual.on_damage_animation, "on_damage")

			-- Spawn damage number particle
			local et = entity.transform or {}
			local damage_number_entity = decore.create_prefab("damage_number")
			damage_number_entity.transform.position_x = et.position_x
			damage_number_entity.transform.position_y = et.position_y + et.size_y/2
			damage_number_entity.transform.position_z = et.position_z
			damage_number_entity.damage_number = math.abs(health_event.damage)

			self.world:addEntity(damage_number_entity)
		end
	end
end


return M
