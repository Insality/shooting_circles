local evolved = require("evolved")
local components = require("components")

local M = {}


function M.register_components()
	---@class components
	---@field lifetime evolved.id
	---@field spawn_on_destroy evolved.id

	components.lifetime = evolved.builder():name("lifetime"):default(1):spawn()
	components.spawn_on_destroy = evolved.builder():name("spawn_on_destroy"):spawn()
end

function M.create_system()
	return evolved.builder()
		:name("lifetime")
		:set(components.system)
		:include(components.lifetime)
		:execute(M.update)
		:spawn()
end


function M.update(chunk, entity_list, entity_count)
	local lifetime = chunk:components(components.lifetime)

	local dt = evolved.get(components.dt, components.dt)
	for index = 1, entity_count do
		lifetime[index] = lifetime[index] - dt
		if lifetime[index] <= 0 then

			if evolved.has(entity_list[index], components.spawn_on_destroy) then
				local prefab = evolved.get(entity_list[index], components.spawn_on_destroy)
				evolved.clone(prefab, {
					[components.position] = evolved.get(entity_list[index], components.position)
				})
			end

			evolved.destroy(entity_list[index])
		end
	end
end


return M
