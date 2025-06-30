local events = require("event.events")
local evolved = require("evolved")
local fragments = require("fragments")

local M = {}

function M.register_fragments()
	---@class fragments
	---@field physics_movement_controller evolved.id

	fragments.physics_movement_controller = evolved.builder():name("physics_movement_controller"):default(0):spawn()
end


local ACTION_ID_TO_SIDE = {
	[hash("key_w")] = { y = 1, id = "up" },
	[hash("key_s")] = { y = -1, id = "down" },
	[hash("key_a")] = { x = -1, id = "left" },
	[hash("key_d")] = { x = 1, id = "right" },
	[hash("key_up")] = { y = 1, id = "up" },
	[hash("key_down")] = { y = -1, id = "down" },
	[hash("key_left")] = { x = -1, id = "left" },
	[hash("key_right")] = { x = 1, id = "right" },
}

local input_keys = {}
local direction_x = 0
local direction_y = 0

events.subscribe("input_event", function(action_id, action)
	local side = ACTION_ID_TO_SIDE[action_id]
	if side then
		if action.pressed then
			input_keys[side.id] = true
		end
		if action.released then
			input_keys[side.id] = nil
		end

		do -- direction_x
			direction_x = 0
			if input_keys["left"] then
				direction_x = direction_x - 1
			end
			if input_keys["right"] then
				direction_x = direction_x + 1
			end
		end

		do -- direction_y
			direction_y = 0
			if input_keys["up"] then
				direction_y = direction_y + 1
			end
			if input_keys["down"] then
				direction_y = direction_y - 1
			end
		end
	end
end)


function M.create_system()
	return evolved.builder()
		:name("system.physics_movement_controller")
		:include(fragments.physics_movement_controller, fragments.velocity, fragments.body_url)
		:set(fragments.system)
		:execute(M.update)
		:spawn()
end


local TEMP_VECTOR = vmath.vector3()
function M.update(chunk, entity_list, entity_count)
	if direction_x == 0 and direction_y == 0 then
		return
	end

	local dt = evolved.get(fragments.dt, fragments.dt)
	local velocity_x, velocity_y = chunk:components(fragments.velocity_x, fragments.velocity_y)
	local body_url = chunk:components(fragments.body_url)

	for index = 1, entity_count do

		local speed = 100000
		TEMP_VECTOR.x = direction_x * speed * dt
		TEMP_VECTOR.y = direction_y * speed * dt
		b2d.body.apply_force_to_center(body_url[index], TEMP_VECTOR)

		--velocity_x[index] = direction_x * speed * dt
		--velocity_y[index] = direction_y * speed * dt
	end
end


return M
