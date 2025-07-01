local queues = require("event.queues")
local evolved = require("evolved")
local fragments = require("fragments")

local M = {}


function M.register_fragments()
	---@class fragments
	---@field collectionfactory_url evolved.id
	---@field game_objects evolved.id
	---@field game_objects_scheme evolved.id

	fragments.game_objects_scheme = evolved.builder():name("game_objects_scheme"):spawn()
	fragments.collectionfactory_url = evolved.builder():require(fragments.transform):name("collectionfactory_url"):spawn()

	fragments.game_objects = evolved.builder():name("game_objects"):on_remove(function(entity, fragment, component)
		for _, game_object in pairs(component) do
			if go.exists(game_object) then
				go.delete(game_object)
			end
		end
	end):spawn()
end


function M.create_system()
	return evolved.builder()
		:name("collectionfactory_object")
		:set(fragments.system)
		:include(fragments.collectionfactory_url)
		:exclude(fragments.root_url)
		:execute(M.create_collectionfactory_object)
		:spawn()
end

local HASH_ROOT = hash("/root")
local PROPERTIES = {
	[HASH_ROOT] = {
		is_spawn_by_system = true,
		parent_entity = nil
	}
}

---@param chunk evolved.chunk
---@param entity_list evolved.id[]
---@param entity_count number
function M.create_collectionfactory_object(chunk, entity_list, entity_count)
	local collectionfactory_url, position, quat, scale_x = chunk:components(fragments.collectionfactory_url, fragments.position, fragments.quat, fragments.scale_x)

	for index = 1, entity_count do
		PROPERTIES[HASH_ROOT].parent_entity = entity_list[index]

		-- Catch all entities created by collectionfactory
		queues.clear("decore.game_objects")
		local objects = collectionfactory.create(collectionfactory_url[index], position[index], quat[index], PROPERTIES, scale_x[index])

		local all_root_urls = queues.get_events("decore.game_objects")
		for root_index = 1, #all_root_urls do
			local root_url = all_root_urls[root_index].data
			pcall(go.set, root_url, "parent_entity", entity_list[index])
		end

		local root_url = objects[HASH_ROOT]
		evolved.set(entity_list[index], fragments.root_url, root_url)
		evolved.set(entity_list[index], fragments.game_objects, objects)
	end
end


return M
