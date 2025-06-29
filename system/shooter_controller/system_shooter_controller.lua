local evolved = require("evolved")
local components = require("components")
local events = require("event.events")
local entities = require("entities")
local camera = require("system.camera")

local M = {}

local HASH_TOUCH = hash("touch")

function M.create_system()
	events.subscribe("input_event", M.on_input_event)

	return evolved.builder()
		:name("shooter_controller")
		:set(components.system)
		:include(components.shooter_controller, components.transform)
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
	if is_pressed then
		-- Create bullet
		local position = chunk:components(components.position)
		local quat = chunk:components(components.quat)

		local pos_x, pos_y = camera.screen_to_world(last_screen_x, last_screen_y)

		for index = 1, entity_count do
			local velocity_x = pos_x - position[index].x
			local velocity_y = pos_y - position[index].y

			local length = math.sqrt(velocity_x * velocity_x + velocity_y * velocity_y)
			velocity_x = velocity_x / length
			velocity_y = velocity_y / length

			velocity_x = velocity_x * 2500
			velocity_y = velocity_y * 2500

			evolved.clone(entities["bullet"], {
				[components.position] = position[index],
				[components.quat] = quat[index],
				[components.velocity_x] = velocity_x,
				[components.velocity_y] = velocity_y,
			})
		end
	end
end

return M
