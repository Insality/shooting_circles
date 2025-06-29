local evolved = require("evolved")
local components = require("components")

local M = {}


function M.register_components()
	---@class components
	---@field lifetime evolved.id

	components.lifetime = evolved.builder():name("lifetime"):default(1):spawn()
end

function M.create_system()
	return evolved.builder()
		:name("system.lifetime")
		:include(components.lifetime)
		:set(components.system)
		:execute(M.update)
		:spawn()
end


function M.update(chunk, entity_list, entity_count)
	local lifetime = chunk:components(components.lifetime)

	local dt = evolved.get(components.dt, components.dt)
	for index = 1, entity_count do
		lifetime[index] = lifetime[index] - dt
		if lifetime[index] <= 0 then
			evolved.destroy(entity_list[index])
		end
	end
end


return M
