local evolved = require("evolved")
local fragments = require("fragments")

local M = {}

function M.register_fragments()
	---@class fragments
	---@field request_play_particlefx evolved.id

	fragments.request_play_particlefx = evolved.builder():name("play_particlefx"):spawn()
end


function M.create_system()
	return evolved.builder()
		:name("play_particlefx")
		:set(fragments.system)
		:include(fragments.request_play_particlefx, fragments.root_url)
		:execute(M.update)
		:spawn()
end


function M.update(chunk, entity_list, entity_count)
	local request_play_particlefx = chunk:components(fragments.request_play_particlefx)
	local root_url = chunk:components(fragments.root_url)

	for index = 1, entity_count do
		local fragment_to_play = request_play_particlefx[index]
		particlefx.play(msg.url(nil, root_url[index], fragment_to_play))
		evolved.remove(entity_list[index], fragments.request_play_particlefx)
	end
end



return M
