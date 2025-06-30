local evolved = require("evolved")
local fragments = require("fragments")
local panthera = require("panthera.panthera")

local M = {}

function M.register_fragments()
	---@class fragments
	---@field panthera_file evolved.id
	---@field panthera_state evolved.id

	fragments.panthera_file = evolved.builder():name("panthera_file"):spawn()
	fragments.panthera_state = evolved.builder():name("panthera_state"):spawn()
end


function M.create_system()
	local group = evolved.id()

	evolved.builder()
		:set(fragments.system)
		:name("panthera.create")
		:group(group)
		:include(fragments.panthera_file, fragments.game_objects)
		:exclude(fragments.panthera_state)
		:execute(M.update_create)
		:spawn()

	return group
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.update_create(chunk, entity_list, entity_count)
	local panthera_file = chunk:components(fragments.panthera_file)
	local game_objects = chunk:components(fragments.game_objects)
	for index = 1, entity_count do
		local state = panthera.create_go(panthera_file[index], nil, game_objects[index])
		evolved.set(entity_list[index], fragments.panthera_state, state)
	end
end


return M
