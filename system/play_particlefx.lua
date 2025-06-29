local evolved = require("evolved")
local components = require("components")

local M = {}

function M.register_components()
	---@class components
	---@field request_play_particlefx evolved.id

	components.request_play_particlefx = evolved.builder():name("play_particlefx"):spawn()
end


function M.create_system()
	return evolved.builder()
		:name("play_particlefx")
		:set(components.system)
		:include(components.request_play_particlefx, components.root_url)
		:execute(M.update)
		:spawn()
end


function M.update(chunk, entity_list, entity_count)
	local request_play_particlefx = chunk:components(components.request_play_particlefx)
	local root_url = chunk:components(components.root_url)

	for index = 1, entity_count do
		local fragment_to_play = request_play_particlefx[index]
		particlefx.play(msg.url(nil, root_url[index], fragment_to_play))
		evolved.remove(entity_list[index], components.request_play_particlefx)
	end
end



return M
