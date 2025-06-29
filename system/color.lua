local evolved = require("evolved")
local components = require("components")

local M = {}

function M.register_components()
	---@class components
	---@field color evolved.id
	---@field color_dirty evolved.id

	components.color = evolved.builder():name("color"):default(vmath.vector4(1, 1, 1, 1)):on_set(function(entity, fragment, new_color, old_color)
		if new_color ~= old_color then
			evolved.set(entity, components.color_dirty)
		end
	end):spawn()
	components.color_dirty = evolved.builder():name("color_dirty"):tag():spawn()
end


function M.create_system()
	return evolved.builder()
		:name("color_system")
		:set(components.system)
		:include(components.color, components.root_url, components.color_dirty)
		:execute(M.update)
		:spawn()
end


function M.update(chunk, entity_list, entity_count)
	local color = chunk:components(components.color)
	local root_url = chunk:components(components.root_url)

	for index = 1, entity_count do
		local sprite_url = msg.url(nil, root_url[index], "sprite")
		go.set(sprite_url, "color", color[index])
		evolved.remove(entity_list[index], components.color_dirty)
	end
end


return M
