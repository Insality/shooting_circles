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
		:name("panthera.create_state")
		:group(group)
		:include(components.panthera_file)
		:exclude(components.panthera_state)
		:execute(M.update_create_state)

	return group
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.update_create_state(chunk, entity_list, entity_count)
	local panthera_file = chunk:components(components.panthera_file)

	for index = 1, entity_count do
		local state = panthera.create_go(panthera_file)
		evolved.set(entity_list[index], components.panthera_state, state)
	end
end


return M
