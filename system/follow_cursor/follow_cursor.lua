local evolved = require("evolved")
local fragments = require("fragments")
local events = require("event.events")
local camera = require("system.camera.camera")

local M = {}

function M.register_fragments()
	---@class fragments
	---@field follow_cursor evolved.id

	fragments.follow_cursor = evolved.builder():tag():name("follow_cursor"):spawn()
end

local last_cursor_pos_x = 0
local last_cursor_pos_y = 0

events.subscribe("input_event", function(action_id, action)
	if action_id then return end
	last_cursor_pos_x = action.screen_x
	last_cursor_pos_y = action.screen_y
end)


function M.create_system()
	return evolved.builder()
		:set(fragments.system)
		:name("follow_cursor")
		:include(fragments.follow_cursor, fragments.position)
		:execute(M.update)
		:spawn()
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.update(chunk, entity_list, entity_count)
	local position = chunk:components(fragments.position)
	for index = 1, entity_count do
		local pos = position[index]
		local world_x, world_y = camera.screen_to_world(last_cursor_pos_x, last_cursor_pos_y)
		pos.x = world_x
		pos.y = world_y
	end
end


return M
