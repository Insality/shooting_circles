local evolved = require("evolved")
local components = require("components")

local M = {}

function M.register_components()
	---@class components
	---@field color_dirty evolved.id
	---@field color evolved.id

	components.color_dirty = evolved.builder():name("color_dirty"):tag():spawn()
	components.color = evolved.builder():name("color"):require(components.color_dirty):default(vmath.vector4(1, 1, 1, 1)):spawn()
end


function M.create_system()
	return evolved.builder()
		:name("color_system")
		:set(components.system)
		:include(components.color, components.game_objects, components.color_dirty)
		:execute(M.update)
		:spawn()
end


---Split string by separator
---@param s string
---@param sep string
function M.split(s, sep)
	sep = sep or "%s"
	local t = {}
	local i = 1
	for str in string.gmatch(s, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end


local function get_target_url(game_objects, sprite_url)
	local parts = M.split(sprite_url, "#")

	local object = game_objects[hash(parts[1])]

	return msg.url(nil, object, parts[2])
end


function M.update(chunk, entity_list, entity_count)
	local color = chunk:components(components.color)
	local game_objects = chunk:components(components.game_objects)

	for index = 1, entity_count do
		for sprite_url, color_value in pairs(color[index]) do
			go.set(get_target_url(game_objects[index], sprite_url), "color", color_value)
		end

		evolved.remove(entity_list[index], components.color_dirty)
	end
end


return M
