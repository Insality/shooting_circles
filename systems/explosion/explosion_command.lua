local ecs = require("decore.ecs")

---@class entity
---@field explosion_command component.explosion_command|nil

---@class entity.explosion_command: entity
---@field explosion_command component.explosion_command

---@class component.explosion_command
---@field explosion component.explosion_command.explosion

---@class component.explosion_command.explosion
---@field power number
---@field position_x number
---@field position_y number
---@field distance number

---@class system.explosion_command: system
---@field entities entity.explosion_command[]
---@field explosion system.explosion
local M = {}


---@static
---@return system.explosion_command
function M.create_system(explosion)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("explosion_command")
	system.explosion = explosion

	return system
end


---@param entity entity.explosion_command
function M:onAdd(entity)
	local command = entity.explosion_command
	if command then
		self:process_command(command)
		self.world:removeEntity(entity)
	end
end


---@param command component.explosion_command
function M:process_command(command)
	if command.explosion then
		local explosion = command.explosion
		local power = explosion.power
		local position_x = explosion.position_x
		local position_y = explosion.position_y

		-- Take all entities with movement and set velocity from explosion position
		for index = 1, #self.explosion.entities do
			local target_entity = self.explosion.entities[index]
			local target_x = target_entity.transform.position_x
			local target_y = target_entity.transform.position_y
			local distance = math.sqrt((target_x - position_x) ^ 2 + (target_y - position_y) ^ 2)
			if distance < explosion.distance then
				local adjusted_power = power * (1 - distance / explosion.distance)
				self.explosion:apply_explosion(target_entity, position_x, position_y, adjusted_power)
			end
		end

		sound.play("/sound#explosion", {
			speed = 0.95 + math.random() * 0.1,
		})
	end
end


return M
