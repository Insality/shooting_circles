local evolved = require("evolved")
local components = require("components")

local M = {}

function M.register_components()
	---@class components
	---@field follow_cursor evolved.id

	components.follow_cursor = evolved.builder():tag():name("follow_cursor"):spawn()
end

local is_dirty = false
local last_cursor_pos_x = 0
local last_cursor_pos_y = 0


function M.create_system()
	return evolved.builder()
		:set(components.system)
		:name("follow_cursor")
		:include(components.follow_cursor, components.position)
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

	local position = chunk:components(components.position)
	for index = 1, entity_count do
		local pos = position[components.position]
		pos.x = last_cursor_pos_x
		pos.y = last_cursor_pos_y
	end
end


return M
