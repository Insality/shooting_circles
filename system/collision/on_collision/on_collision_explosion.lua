local decore = require("decore.decore")

---@class entity
---@field on_collision_explosion component.on_collision_explosion|nil

---@class entity.on_collision_explosion: entity
---@field on_collision_explosion boolean

---@class component.on_collision_explosion
---@field power number
---@field distance number
---@field damage number
---@field spawn_entity string|nil
decore.register_component("on_collision_explosion", {
	power = 0,
	distance = 0,
	damage = 0,
})

---@class system.on_collision_explosion: system
---@field entities entity.physics[]
local M = {}


---@static
---@return system.on_collision_explosion
function M.create()
	local self = decore.system(M, "on_collision_explosion", { "physics" })
	self.play_sound_timer = 0
	return self
end


function M:postWrap()
	self.world.event_bus:process("collision_event", self.process_collision_events, self)
end


---@param collision_events system.collision.event[]
function M:process_collision_events(collision_events)
	for _, collision_event in ipairs(collision_events) do
		local entity = collision_event.entity

		local on_collision_explosion = entity.on_collision_explosion
		if on_collision_explosion then
			local explosion = on_collision_explosion
			local power = explosion.power
			local position_x = entity.transform.position_x
			local position_y = entity.transform.position_y

			-- Take all entities with movement and set velocity from explosion position
			for index = 1, #self.entities do
				local target_entity = self.entities[index]
				local target_x = target_entity.transform.position_x
				local target_y = target_entity.transform.position_y
				local distance = math.sqrt((target_x - position_x) ^ 2 + (target_y - position_y) ^ 2)
				if distance < explosion.distance then
					local koef = 1 - distance / explosion.distance

					local adjusted_power = power * koef
					self:apply_explosion_force(target_entity, position_x, position_y, adjusted_power)

					local damage = math.ceil(explosion.damage * koef)
					if damage > 0 and target_entity.health then
						self.world.health:apply_damage(target_entity, damage)
					end
				end
			end

			if self.play_sound_timer == 0 then
				sound.play("/sound#explosion", {
					speed = 0.95 + math.random() * 0.1,
				})
				self.play_sound_timer = 0.1
			end

			local shake_power = 4
			local time = 0.4
			if explosion.power > 20000 then
				power = 10
				time = 0.6
			end

			self.world.camera:shake(shake_power, time)

			local explosion_entity = decore.create_prefab(explosion.spawn_entity or "explosion")
			if explosion_entity then
				explosion_entity.transform.position_x = position_x
				explosion_entity.transform.position_y = position_y
				explosion_entity.transform.position_z = 10
				self.world:addEntity(explosion_entity)
			end
		end
	end
end


---@param entity entity.physics
---@param position_x number
---@param position_y number
---@param power number
function M:apply_explosion_force(entity, position_x, position_y, power)
	local target_x = entity.transform.position_x
	local target_y = entity.transform.position_y
	local force_x = target_x - position_x
	local force_y = target_y - position_y
	local distance = math.sqrt(force_x * force_x + force_y * force_y)
	distance = math.max(1, distance)
	force_x = force_x / distance * power
	force_y = force_y / distance * power

	self.world.command_physics:add_force(entity, force_x, force_y)
end


function M:update(dt)
	if self.play_sound_timer > 0 then
		self.play_sound_timer = math.max(self.play_sound_timer - dt, 0)
	end
end


return M
