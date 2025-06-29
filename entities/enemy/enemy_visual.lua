local evolved = require("evolved")
local components = require("components")
local panthera = require("panthera.panthera")

local M = {}


local function clone_state(state)
	return {
		progress = state.progress,
	}
end

function M.register_components()
	---@class components
	---@field enemy_visual evolved.id

	components.enemy_visual = evolved.builder():name("enemy_visual"):default({
		progress = 0,
	}):duplicate(clone_state):spawn()
end


function M.register_system()
	return evolved.builder()
		:name("enemy_visual")
		:set(components.system)
		:include(components.enemy_visual, components.panthera_state, components.health)
		:execute(M.update)
		:spawn()
end


function M.update(chunk, entity_list, entity_count)
	local enemy_visual, panthera_state = chunk:components(components.enemy_visual, components.panthera_state)
	local health, health_max = chunk:components(components.health, components.health_max)

	for index = 1, entity_count do
		local progress = health[index] / health_max[index]
		progress = math.max(0, math.min(1, progress))

		if progress ~= enemy_visual[index].progress then
			enemy_visual[index].progress = progress
			panthera.set_time(panthera_state[index], "health", progress)
			panthera.play_detached(panthera_state[index], "on_hit")
		end
	end
end




return M
