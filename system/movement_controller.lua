local events = require("event.events")
local evolved = require("evolved")
local components = require("components")


local M = {}

function M.register_components()
	---@class components
	---@field movement_controller evolved.id

	components.movement_controller = evolved.builder():name("movement_controller"):default(0):spawn()
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
		:name("system.movement_controller")
		:include(components.movement_controller, components.position)
		:set(components.system)
		:execute(M.update)
		:spawn()
end


function M.update(chunk, entity_list, entity_count)
	if direction_x == 0 and direction_y == 0 then
		return
	end

	local dt = evolved.get(components.dt, components.dt)
	local movement_controller, position = chunk:components(components.movement_controller, components.position)

	for index = 1, entity_count do
		local speed = movement_controller[index]
		position[index].x = position[index].x + direction_x * speed * dt
		position[index].y = position[index].y + direction_y * speed * dt
	end
end


return M
