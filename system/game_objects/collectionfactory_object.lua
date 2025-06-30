local evolved = require("evolved")
local components = require("components")

local M = {}


function M.register_components()
	---@class components
	---@field collectionfactory_url evolved.id
	---@field game_objects evolved.id
	---@field game_objects_scheme evolved.id

	components.collectionfactory_url = evolved.builder():require(components.transform):name("collectionfactory_url"):spawn()
	components.game_objects = evolved.builder():name("game_objects"):on_remove(function(entity, fragment, component)
		for _, game_object in pairs(component) do
			go.delete(game_object)
		end
	end):spawn()
	components.game_objects_scheme = evolved.builder():name("game_objects_scheme"):spawn()
end


function M.create_system()
	return evolved.builder()
		:name("collectionfactory_object")
		:set(components.system)
		:include(components.collectionfactory_url)
		:exclude(components.root_url)
		:execute(M.create_collectionfactory_object)
		:spawn()
end

local PROPERTIES = {
	[hash("/root")] = {
		is_spawn_by_system = true
	}
}

---@param chunk evolved.chunk
---@param entity_list evolved.id[]
---@param entity_count number
function M.create_collectionfactory_object(chunk, entity_list, entity_count)
	local collectionfactory_url, position, quat, scale_x = chunk:components(components.collectionfactory_url, components.position, components.quat, components.scale_x)

	for index = 1, entity_count do
		local objects = collectionfactory.create(collectionfactory_url[index], position[index], quat[index], PROPERTIES, scale_x[index])
		local root_url = objects[hash("/root")]
		evolved.set(entity_list[index], components.root_url, root_url)
		evolved.set(entity_list[index], components.game_objects, objects)
	end
end


return M
