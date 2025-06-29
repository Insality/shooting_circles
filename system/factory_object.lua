local evolved = require("evolved")
local components = require("components")

local M = {}


function M.register_components()
	---@class components
	---@field factory_url evolved.id

	components.factory_url = evolved.builder():require(components.transform):name("factory_url"):spawn()
end


function M.create_system()
	return evolved.builder()
		:name("factory_object")
		:set(components.system)
		:include(components.factory_url)
		:exclude(components.root_url)
		:execute(M.create_factory_object)
		:spawn()
end

local PROPERTIES = {
	is_spawn_by_system = true
}

---@param chunk evolved.chunk
---@param entity_list evolved.id[]
---@param entity_count number
function M.create_factory_object(chunk, entity_list, entity_count)
	local factory_url, position, quat, scale_x = chunk:components(components.factory_url, components.position, components.quat, components.scale_x)

	for index = 1, entity_count do
		-- if sync_game_object_position is goes after this system, for some reason the exclude is not working
		-- so we need to check if the entity has root_url and if it does, we need to remove it
		-- How to do better?
		-- Only if sync goes first
		-- Oh seems the component.root_url is nil, so need to register them first somehow
		if not evolved.has(entity_list[index], components.root_url) then
			local object = factory.create(factory_url[index], position[index], quat[index], PROPERTIES, scale_x[index])
			evolved.set(entity_list[index], components.root_url, object)
		end
	end
end


return M
