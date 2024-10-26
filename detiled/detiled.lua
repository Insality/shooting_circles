local decore = require("decore.decore")
local detiled_internal = require("detiled.detiled_internal")
local detiled_decore = require("detiled.detiled_decore")

---@class detiled
local M = {}


function M.init()
	decore.register_components({
		pack_id = "detiled",
		components = {
			name = false,
			tiled_id = false,
			layer_id = false,
		}
	})
end


---@param logger_instance detiled.logger|table|nil
function M.set_logger(logger_instance)
	detiled_internal.logger = logger_instance or detiled_internal.empty_logger
end


---@param tilesets_path string
---@return decore.entities_pack_data[]|nil
function M.get_entities_packs_data(tilesets_path)
	local tileset_list = detiled_internal.load_json(tilesets_path)
	if not tileset_list then
		return
	end

	local entity_packs = {}
	for index = 1, #tileset_list.tilesets do
		local tileset_path = tileset_list.tilesets[index]

		local entities = detiled_decore.create_entities_from_tiled_tileset(tileset_path)
		if entities then
			table.insert(entity_packs, entities)
		end
	end

	return entity_packs
end


---@return table<string, entity>
function M.get_entities_from_tileset(tileset_path)
	return detiled_decore.create_entities_from_tiled_tileset(tileset_path)
end


---@param map_path string
---@return decore.world.instance
function M.get_world_from_tiled_map(map_path)
	return detiled_decore.create_world_from_tiled_map(map_path)
end


---@param maps_list_path string|table
---@return decore.worlds_pack_data[]
function M.get_worlds_from_tiled_maps(maps_list_path)
	local map_list = detiled_internal.load_config(maps_list_path)
	if not map_list then
		return {}
	end

	local worlds_pack = {}

	for map_id, map_path in pairs(map_list) do
		local world = detiled_decore.create_world_from_tiled_map(map_path)
		if world then
			worlds_pack[map_id] = world
		end
	end

	return worlds_pack
end


function M.merge_arrays(...)
	local arrays = {...}
	local merged_array = {}
	for _, array in ipairs(arrays) do
		for i = 1, #array do
			table.insert(merged_array, array[i])
		end
	end
	return merged_array
end


return M
