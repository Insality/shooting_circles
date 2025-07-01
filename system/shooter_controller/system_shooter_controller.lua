local evolved = require("evolved")
local fragments = require("fragments")
local events = require("event.events")
local camera = require("system.camera.camera")

local M = {}

local HASH_TOUCH = hash("touch")

function M.create_system()
	events.subscribe("input_event", M.on_input_event)

	return evolved.builder()
		:name("shooter_controller")
		:set(fragments.system)
		:include(fragments.shooter_controller, fragments.transform)
		:execute(M.update)
		:spawn()
end


local last_screen_x = 0
local last_screen_y = 0
local is_pressed = false


---@param action_id hash
---@param action table
function M.on_input_event(action_id, action)
	if action_id == HASH_TOUCH then
		if action.pressed then
			is_pressed = true
		end
		if action.released then
			is_pressed = false
		end
		last_screen_x = action.screen_x
		last_screen_y = action.screen_y
	end
end

function M.update(chunk, entity_list, entity_count)
	local shooter_controller = chunk:components(fragments.shooter_controller)
	local position = chunk:components(fragments.position)
	local quat = chunk:components(fragments.quat)
	local dt = evolved.get(fragments.dt, fragments.dt)

	local pos_x, pos_y = camera.screen_to_world(last_screen_x, last_screen_y)

	for index = 1, entity_count do
		local controller = shooter_controller[index]
		controller.current_cooldown = controller.current_cooldown or 0
		controller.spread_euler = controller.spread_euler or 5

		if is_pressed and controller.current_cooldown == 0 then
			local velocity_x = pos_x - position[index].x
			local velocity_y = pos_y - position[index].y

			local length = math.sqrt(velocity_x * velocity_x + velocity_y * velocity_y)
			velocity_x = velocity_x / length
			velocity_y = velocity_y / length

			-- Add spread to the angle
			local base_angle = math.atan2(velocity_y, velocity_x)
			local spread_radians = math.rad(controller.spread_euler)
			local random_spread = (math.random() - 0.5) * spread_radians
			local final_angle = base_angle + random_spread

			velocity_x = math.cos(final_angle) * 2500
			velocity_y = math.sin(final_angle) * 2500

			evolved.clone(controller.prefab, {
				[fragments.position] = position[index],
				[fragments.quat] = quat[index],
				[fragments.velocity_x] = velocity_x,
				[fragments.velocity_y] = velocity_y,
			})
			controller.shoot_count = controller.shoot_count + 1

			controller.current_cooldown = controller.cooldown
		end

		if controller.current_cooldown > 0 then
			controller.current_cooldown = math.max(0, controller.current_cooldown - dt)
		end
	end
end

return M
