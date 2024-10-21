local ecs = require("decore.ecs")
local decore = require("decore.decore")

---@class entity
---@field health_circle_visual_command component.health_circle_visual_command|nil

---@class entity.health_circle_visual_command: entity
---@field health_circle_visual_command component.health_circle_visual_command

---@class component.health_circle_visual_command
---@field sprite_url string
---@field health_color string

---@class system.health_circle_visual_command: system
---@field entities entity.health_circle_visual_command[]
---@field health_circle_visual system.health_circle_visual
local M = {}


---@static
---@return system.health_circle_visual_command
function M.create_system(health_circle_visual)
	local system = setmetatable(ecs.system(), { __index = M })
	system.health_circle_visual = health_circle_visual

	return system
end


function M:postWrap()
	self.world.queue:process("health_event", self.process_health_event, self)
end


---@param health_event event.health_event
function M:process_health_event(health_event)

	local entity = health_event.entity
	if entity.health_circle_visual and health_event.damage then
		local progress = entity.health.current_health / entity.health.health
		self.world.panthera_command:set_progress(entity, "health", progress)
		self.world.panthera_command:play_detached(entity, "on_damage")

		-- Spawn damage number particle
		local et = entity.transform or {}
		local damage_number_entity = decore.create_entity("damage_number", nil, {
			transform = {
				position_x = et.position_x,
				position_y = et.position_y + et.size_y/2,
				position_z = et.position_z,
			},
			damage_number = {
				damage = math.abs(health_event.damage),
			},
		})
		self.world:addEntity(damage_number_entity)
	end
end


return M
