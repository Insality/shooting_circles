local evolved = require("evolved")
local components = require("components")
local panthera = require("panthera.panthera")

local M = {}

function M.register_components()
	---@class components
	---@field panthera_file evolved.id
	---@field panthera_state evolved.id

	components.panthera_file = evolved.builder():name("panthera_file"):spawn()
	components.panthera_state = evolved.builder():name("panthera_state"):spawn()
end


function M.create_system()
	local group = evolved.id()

	evolved.builder()
		:set(components.system)
		:name("panthera.create")
		:group(group)
		:include(components.panthera_file, components.game_objects)
		:exclude(components.panthera_state)
		:execute(M.update_create)
		:spawn()

	return group
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.update_create(chunk, entity_list, entity_count)
	local panthera_file = chunk:components(components.panthera_file)
	local game_objects = chunk:components(components.game_objects)
	for index = 1, entity_count do
		local state = panthera.create_go(panthera_file[index], nil, game_objects[index])
		evolved.set(entity_list[index], components.panthera_state, state)
	end
end


return M
