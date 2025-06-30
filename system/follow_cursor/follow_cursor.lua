local evolved = require("evolved")
local fragments = require("fragments")

local M = {}

function M.register_fragments()
	---@class fragments
	---@field follow_cursor evolved.id

	fragments.follow_cursor = evolved.builder():tag():name("follow_cursor"):spawn()
end

local is_dirty = false
local last_cursor_pos_x = 0
local last_cursor_pos_y = 0


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
	if not is_dirty then
		return
	end

	local position = chunk:components(fragments.position)
	for index = 1, entity_count do
		local pos = position[fragments.position]
		pos.x = last_cursor_pos_x
		pos.y = last_cursor_pos_y
	end
end


return M
