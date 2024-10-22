local decore = require("decore.decore")
local panthera = require("panthera.panthera")

---@class entity
---@field health_circle_visual component.health_circle_visual|nil

---@class entity.health_circle_visual: entity
---@field health_circle_visual component.health_circle_visual
---@field health component.health

---@class component.health_circle_visual
---@field on_damage_animation panthera.animation.state

---@class system.health_circle_visual: system
---@field entities entity.health_circle_visual[]
local M = {}


---@static
---@return system.health_circle_visual
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("health_circle_visual", "health")
	system.id = "health_circle_visual"

	return system
end


function M:postWrap()
	self.world.queue:process("health_event", self.process_health_event, self)
end


---@param entity entity.health_circle_visual
function M:onAdd(entity)
	entity.health_circle_visual.on_damage_animation = panthera.clone_state(entity.panthera.animation_state)
end


---@param health_event event.health_event
function M:process_health_event(health_event)
	local entity = health_event.entity
	if entity.health_circle_visual and health_event.damage then
		local progress = entity.health.current_health / entity.health.health
		self.world.panthera_command:set_progress(entity, "health", progress)
		self.world.panthera_command:play_state(entity, entity.health_circle_visual.on_damage_animation, "on_damage")

		-- Spawn damage number particle
		local et = entity.transform or {}
		local damage_number_entity = decore.create_entity("damage_number")
		damage_number_entity.transform.position_x = et.position_x
		damage_number_entity.transform.position_y = et.position_y + et.size_y/2
		damage_number_entity.transform.position_z = et.position_z
		damage_number_entity.damage_number = math.abs(health_event.damage)

		self.world:addEntity(damage_number_entity)
	end
end


return M
