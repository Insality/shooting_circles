local evolved = require("evolved")
local fragments = require("fragments")

local M = {}


function M.register_fragments()
	---@class fragments
	---@field lifetime evolved.id
	---@field spawn_on_destroy evolved.id

	fragments.lifetime = evolved.builder():name("lifetime"):default(1):spawn()
	fragments.spawn_on_destroy = evolved.builder():name("spawn_on_destroy"):spawn()
end

function M.create_system()
	return evolved.builder()
		:name("lifetime")
		:set(fragments.system)
		:include(fragments.lifetime)
		:execute(M.update)
		:spawn()
end


function M.update(chunk, entity_list, entity_count)
	local lifetime = chunk:components(fragments.lifetime)
	local dt = evolved.get(fragments.dt, fragments.dt)

	for index = 1, entity_count do
		local entity = entity_list[index]
		lifetime[index] = lifetime[index] - dt

		if lifetime[index] <= 0 then
			if evolved.has(entity, fragments.spawn_on_destroy) then
				local prefab = evolved.get(entity, fragments.spawn_on_destroy)
				evolved.clone(prefab, {
					[fragments.position] = evolved.get(entity, fragments.position)
				})
			end

			evolved.destroy(entity)
		end
	end
end


return M
