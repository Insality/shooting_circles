local detiled_internal = require("detiled.detiled_internal")
local detiled_decore = require("detiled.detiled_decore")

---@class detiled
local M = {}


---@param logger_instance logger|nil
function M.set_logger(logger_instance)
	detiled_internal.logger = logger_instance
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


---@param maps_list_path string
---@return decore.worlds_pack_data[]|nil
function M.get_worlds_packs_data(maps_list_path)
	local map_list = detiled_internal.load_json(maps_list_path)
	if not map_list then
		return
	end

	local world_packs = {}
	for pack_id, maps_table in pairs(map_list) do
		---@type decore.worlds_pack_data
		local world_pack = {
			pack_id = pack_id,
			worlds = {}
		}

		for map_id, map_path in pairs(maps_table) do
			local worlds = detiled_decore.create_worlds_from_tiled_map(map_id, map_path)
			if worlds then
				for world_id, world in pairs(worlds) do
					world_pack.worlds[world_id] = world
				end
			end
		end

		table.insert(world_packs, world_pack)
	end

	return world_packs
end


return M
