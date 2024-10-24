local decore = require("decore.decore")

local logger = decore.get_logger("shooter_controller")

---@class entity
---@field shooter_controller component.shooter_controller|nil

---@class entity.shooter_controller: entity
---@field shooter_controller component.shooter_controller

---@class component.shooter_controller
---@field bullet_prefab_id string
---@field bullet_speed number
---@field damage number
---@field spread_angle number @In degrees
---@field is_auto_shoot boolean
---@field fire_rate number
---@field fire_rate_timer number
---@field burst_count number
---@field burst_count_current number
---@field burst_rate number
---@field last_screen_x number
---@field last_screen_y number
---@field bullets_per_shoot number
decore.register_component("shooter_controller", {
	bullet_prefab_id = "",
	bullet_speed = 0,
	damage = 0,
	spread_angle = 0,
	is_auto_shoot = false,
	fire_rate = 0,
	fire_rate_timer = 0,
	burst_count = 0,
	burst_count_current = 0,
	burst_rate = 0,
	last_screen_x = 0,
	last_screen_y = 0,
	bullets_per_shoot = 1,
})

---@class system.shooter_controller: system
---@field entities entity.shooter_controller[]
local M = {}

local HASH_TOUCH = hash("touch")
local HASH_SPACE = hash("key_space")

---@static
---@return system.shooter_controller
function M.create_system()
	local system = setmetatable(decore.ecs.processingSystem(), { __index = M })
	system.filter = decore.ecs.requireAll("shooter_controller")

	return system
end


function M:postWrap()
	self.world.queue:process("input_event", self.process_input_event, self)
end


---@param input_event event.input_event
function M:process_input_event(input_event)
	for _, entity in ipairs(self.entities) do
		self:apply_input_event(entity, input_event)
	end
end


---@param entity entity.shooter_controller
---@param input_event event.input_event
function M:apply_input_event(entity, input_event)
	local action_id = input_event.action_id
	local action = input_event
	local sc = entity.shooter_controller

	if action.screen_x and action.screen_y then
		sc.last_screen_x = action.screen_x
		sc.last_screen_y = action.screen_y
	end

	if action_id == HASH_TOUCH or action_id == HASH_SPACE then
		if action.pressed then
			sc.burst_count_current = 0
			self:shoot_at(entity, sc.last_screen_x, sc.last_screen_y)
		else
			if sc.is_auto_shoot then
				if sc.fire_rate_timer == 0 then
					self:shoot_at(entity, sc.last_screen_x, sc.last_screen_y)
				end
			end
		end
	end
end


---@param entity entity.shooter_controller
---@param screen_x number
function M:shoot_at(entity, screen_x, screen_y)
	local sc = entity.shooter_controller
	sc.fire_rate_timer = entity.shooter_controller.fire_rate

	if sc.burst_count > 0 then
		if sc.burst_count_current == 0 then
			sc.burst_count_current = sc.burst_count
		end

		sc.burst_count_current = sc.burst_count_current - 1
		if sc.burst_count_current == 0 then
			sc.fire_rate_timer = sc.burst_rate
		end
	end

	local vary = 0.3
	for _ = 1, sc.bullets_per_shoot do
		local bullet_entity = decore.create_entity(entity.shooter_controller.bullet_prefab_id)
		if not bullet_entity then
			logger:error("Failed to create bullet entity", entity.shooter_controller)
			return
		end

		bullet_entity.transform.position_x = entity.transform.position_x
		bullet_entity.transform.position_y = entity.transform.position_y

		local speed = entity.shooter_controller.bullet_speed
		local spread_angle = entity.shooter_controller.spread_angle
		local world_x, world_y = self.world.camera_command:screen_to_world(screen_x, screen_y)

		local velocity_x = world_x - entity.transform.position_x
		local velocity_y = world_y - entity.transform.position_y
		local length = math.sqrt(velocity_x * velocity_x + velocity_y * velocity_y)
		velocity_x = velocity_x / length
		velocity_y = velocity_y / length

		local current_angle = math.atan2(velocity_y, velocity_x)
		local new_angle = current_angle + (math.random() - 0.5) * math.rad(spread_angle)
		velocity_x = math.cos(new_angle)
		velocity_y = math.sin(new_angle)

		bullet_entity.physics.velocity_x = velocity_x * speed * (1 + (math.random() - 0.5) * vary)
		bullet_entity.physics.velocity_y = velocity_y * speed * (1 + (math.random() - 0.5) * vary)

		bullet_entity.transform.rotation = math.deg(new_angle) + 90

		self.world:addEntity(bullet_entity)
	end

	sound.play("/sound#laser_shoot", {
		speed = 0.9 + math.random() * 0.2,
	})
end


---@param entity entity.shooter_controller
---@param dt number
function M:process(entity, dt)
	local shooter_controller = entity.shooter_controller
	if shooter_controller.fire_rate_timer > 0 then
		shooter_controller.fire_rate_timer = math.max(shooter_controller.fire_rate_timer - dt, 0)
	end
end


return M
