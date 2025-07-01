local evolved = require("evolved")
local fragments = require("fragments")

local M = {}


function M.register_fragments()
	---@class fragments
	---@field lifetime evolved.id
	---@field spawn_on_destroy evolved.id

	fragments.lifetime = evolved.builder():name("lifetime"):default(1):spawn()
	fragments.spawn_on_destroy = evolved.builder()
		:name("spawn_on_destroy")
		:spawn()
end


function M.create_system()
	return evolved.builder()
		:name("lifetime")
		:set(fragments.system)
		:include(fragments.lifetime)
		:execute(M.update)
		:spawn()
end


---@param chunk evolved.chunk
---@param entity_list evolved.id[]
---@param entity_count number
function M.update(chunk, entity_list, entity_count)
	local dt = evolved.get(fragments.dt, fragments.dt)
	local lifetime, spawn_on_destroy, position = chunk:components(fragments.lifetime, fragments.spawn_on_destroy, fragments.position)

	for index = 1, entity_count do
		lifetime[index] = lifetime[index] - dt

		if lifetime[index] <= 0 then
			local prefab = spawn_on_destroy[index]
			if prefab then
				evolved.clone(prefab, { [fragments.position] = position[index] })
			end

			evolved.destroy(entity_list[index])
		end
	end
end


return M
