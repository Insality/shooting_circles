local evolved = require("evolved")
local fragments = require("fragments")
local panthera = require("panthera.panthera")
local damage_number = require("entity.damage_number.damage_number")

local M = {}


local function clone_state(state)
	return {
		progress = state.progress,
		last_health = state.last_health,
	}
end

function M.register_fragments()
	---@class fragments
	---@field enemy_visual evolved.id

	fragments.enemy_visual = evolved.builder():name("enemy_visual"):default({
		progress = 0,
		last_health = nil,
	}):duplicate(clone_state):spawn()
end


function M.create_system()
	return evolved.builder()
		:name("enemy_visual")
		:set(fragments.system)
		:include(fragments.enemy_visual, fragments.panthera_state, fragments.health)
		:execute(M.update)
		:spawn()
end


function M.update(chunk, entity_list, entity_count)
	local enemy_visual, panthera_state = chunk:components(fragments.enemy_visual, fragments.panthera_state)
	local health, health_max = chunk:components(fragments.health, fragments.health_max)

	for index = 1, entity_count do
		local progress = health[index] / health_max[index]
		progress = math.max(0, math.min(1, progress))

		if not enemy_visual[index].last_health or enemy_visual[index].last_health ~= health[index] then
			if not enemy_visual[index].last_health then
				enemy_visual[index].last_health = health[index]
			end

			local damage = enemy_visual[index].last_health - health[index]
			if damage > 0 then
				evolved.clone(damage_number, {
					[fragments.position] = evolved.get(entity_list[index], fragments.position),
					[fragments.damage_number] = damage,
				})
			end

			enemy_visual[index].progress = progress
			enemy_visual[index].last_health = health[index]

			panthera.set_time(panthera_state[index], "health", progress)
			panthera.play_detached(panthera_state[index], "on_hit")
		end
	end
end


return M
