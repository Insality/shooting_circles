local evolved = require("evolved")
local fragments = require("fragments")

local M = {}


function M.register_fragments()
	---@class fragments
	---@field factory_url evolved.id

	fragments.factory_url = evolved.builder():require(fragments.transform):name("factory_url"):spawn()
end


function M.create_system()
	return evolved.builder()
		:name("factory_object")
		:set(fragments.system)
		:include(fragments.factory_url)
		:exclude(fragments.root_url)
		:execute(M.create_factory_object)
		:spawn()
end

local PROPERTIES = {
	is_spawn_by_system = true,
	parent_entity = nil
}

---@param chunk evolved.chunk
---@param entity_list evolved.id[]
---@param entity_count number
function M.create_factory_object(chunk, entity_list, entity_count)
	local factory_url, position, quat, scale_x = chunk:components(fragments.factory_url, fragments.position, fragments.quat, fragments.scale_x)

	for index = 1, entity_count do
		if not evolved.has(entity_list[index], fragments.root_url) then
			PROPERTIES.parent_entity = entity_list[index]
			local object = factory.create(factory_url[index], position[index], quat[index], PROPERTIES, scale_x[index])
			evolved.set(entity_list[index], fragments.root_url, object)
		end
	end
end


return M
