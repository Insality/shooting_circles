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
	system.filter = ecs.requireAny("health_event")
	system.health_circle_visual = health_circle_visual

	return system
end


---@param entity entity.health_circle_visual_command
function M:onAdd(entity)
	local health_event = entity.health_event
	if health_event then
		self:process_health_event(health_event)
	end
end


---@param health_event component.health_event
function M:process_health_event(health_event)
	local entity = health_event.entity
	if entity.health_circle_visual and health_event.damage then
		local progress = entity.health.current_health / entity.health.health
		---@type component.panthera_command
		local panthera_command = {
			entity = entity,
			animation_id = "health",
			progress = progress,
		}
		self.world:addEntity({ panthera_command = panthera_command })

		---@type component.panthera_command
		local panthera_command = {
			entity = entity,
			detached = true,
			animation_id = "on_damage",
		}
		self.world:addEntity({ panthera_command = panthera_command })

		-- Spawn damage number particle
		local damage_number_entity = decore.create_entity("damage_number")
		if damage_number_entity then
			local t = damage_number_entity.transform
			local et = entity.transform
			if et then
				t.position_x = et.position_x
				t.position_y = et.position_y + et.size_y/2
				t.position_z = et.position_z
			end

			damage_number_entity.damage_number.damage = math.abs(health_event.damage)

			self.world:addEntity(damage_number_entity)
		end
	end
end


return M
