local detiled_internal = require("detiled.detiled_internal")


local M = {}
local LAYER_TILE = "tilelayer"
local LAYER_OBJECTS = "objectgroup"


---@param layer detiled.map.layer
---@param map detiled.map
---@return decore.entities_pack_data.instance[]
local function get_entities_from_tile_layer(layer, map)
	---@type decore.entities_pack_data.instance[]
	local entities = {}

	local map_height = map.height * map.tileheight
	local position_z = detiled_internal.get_property_value(layer.properties, "position_z") or 0

	for tile_index = 1, #layer.data do
		local tile_gid = layer.data[tile_index]
		local tile, tileset = detiled_internal.get_tile_by_gid(map, tile_gid)
		if tile and tileset then
			local tile_i = ((tile_index - 1) % map.width)
			local tile_j = (math.floor((tile_index - 1) / map.width)) + 1
			local pos_x = tile_i * map.tilewidth
			local pos_y = tile_j * map.tileheight

			---@type decore.entities_pack_data.instance
			local entity = {}
			entity.prefab_id = tile.class
			entity.components = {
				prefab_id = tile.class,
				layer_id = layer.name,
				transform = {
					position_x = pos_x,
					position_y = map_height - pos_y,
					position_z = position_z,
				}
			}

			table.insert(entities, entity)
		end
	end

	return entities
end


---@param layer detiled.map.layer
---@param map detiled.map
---@return decore.entities_pack_data.instance[]
local function get_entities_from_object_layer(layer, map)
	---@type decore.entities_pack_data.instance[]
	local entities = {}

	local map_height = map.height * map.tileheight
	local position_z = detiled_internal.get_property_value(layer.properties, "position_z") or 0

	for object_index = 1, #layer.objects do
		local object = layer.objects[object_index]
		local rotation = -object.rotation

		local object_gid = object.gid
		if object_gid then -- If object has a tileset, spawn from tileset
			local tile, tileset = detiled_internal.get_tile_by_gid(map, object_gid)
			if tile and tileset then
				local entity = {}
				local position_x, position_y, scale_x, scale_y = M.get_defold_position_from_tiled_object(object, tile, map_height)
				position_x = position_x + (layer.offsetx or 0)
				position_y = position_y - (layer.offsety or 0)

				local components = {
					name = object.name ~= "" and object.name or nil,
					prefab_id = tile.class,
					tiled_id = tostring(object.id),
					layer_id = layer.name,

					transform = {
						position_x = position_x,
						position_y = position_y,
						position_z = position_z,
						size_x = object.width,
						size_y = object.height,
						scale_x = scale_x ~= 1 and scale_x or nil,
						scale_y = scale_y ~= 1 and scale_y or nil,
						rotation = rotation,
					}
				}

				if object.properties then
					local tiled_components = detiled_internal.get_components_property(object.properties)
					if tiled_components then
						-- Unique case
						if tiled_components.position_z then
							components.transform.position_z = components.transform.position_z + tiled_components.position_z
							tiled_components.position_z = nil
						end

						detiled_internal.apply_components(components, tiled_components)
					end
				end

				entity.prefab_id = tile.class
				entity.components = components

				table.insert(entities, entity)
			end
		elseif object.class and object.class ~= "" then -- If object not from tileset and has a prefab to spawn
			local entity = {}
			local position_x, position_y, scale_x, scale_y = M.get_defold_position_from_tiled_object(object, nil, map_height)
			--position_y = map_height - position_y
			position_x = position_x + (layer.offsetx or 0)
			position_y = position_y - (layer.offsety or 0)
			position_y = position_y - object.height

			local components = {
				name = object.name ~= "" and object.name or nil,
				prefab_id = object.class ~= "" and object.class or nil,
				tiled_id = object.id,
				layer_id = layer.name,

				transform = {
					position_x = position_x,
					position_y = position_y,
					position_z = position_z,
					size_x = object.width,
					size_y = object.height,
					scale_x = scale_x ~= 1 and scale_x or nil,
					scale_y = scale_y ~= 1 and scale_y or nil,
					rotation = rotation,
				}
			}

			if object.properties then
				local tiled_components = detiled_internal.get_components_property(object.properties)
				if tiled_components then
					-- Unique case
					if tiled_components.position_z then
						components.transform.position_z = components.transform.position_z + tiled_components.position_z
						tiled_components.position_z = nil
					end

					detiled_internal.apply_components(components, tiled_components)
				end
			end

			entity.prefab_id = object.class
			entity.components = components

			table.insert(entities, entity)
		else -- Empty object from tiled
			local position_x, position_y, scale_x, scale_y = M.get_defold_position_from_tiled_object(object, nil, map_height)
			position_x = position_x + (layer.offsetx or 0)
			position_y = position_y - (layer.offsety or 0)
			position_y = position_y - object.height

			local entity = {
				components = {
					name = object.name ~= "" and object.name or nil,
					tiled_id = object.id,
					layer_id = layer.name,

					transform = {
						position_x = position_x,
						position_y = position_y,
						position_z = position_z,
						size_x = object.width,
						size_y = object.height,
						rotation = rotation,
					}
				}
			}

			if object.properties then
				local tiled_components = detiled_internal.get_components_property(object.properties)
				if tiled_components then
					-- Unique case
					if tiled_components.position_z then
						entity.components.transform.position_z = entity.components.transform.position_z + tiled_components.position_z
						tiled_components.position_z = nil
					end

					detiled_internal.apply_components(entity.components, tiled_components)
				end
			end

			table.insert(entities, entity)
		end
	end

	return entities
end


---@param tiled_map detiled.map
---@return decore.entities_pack_data.instance[]
function M.get_entities(tiled_map)
	---@type decore.entities_pack_data.instance[]
	local entities = {}

	for layer_index = 1, #tiled_map.layers do
		local layer = tiled_map.layers[layer_index]

		if layer.type == LAYER_TILE then
			local layer_entities = get_entities_from_tile_layer(layer, tiled_map)
			for index = 1, #layer_entities do
				table.insert(entities, layer_entities[index])
			end
		end

		if layer.type == LAYER_OBJECTS then
			local layer_entities = get_entities_from_object_layer(layer, tiled_map)
			for index = 1, #layer_entities do
				table.insert(entities, layer_entities[index])
			end
		end
	end

	return entities
end


---@param tiled_map detiled.map
---@param layer_name string
function M.is_layer_excluded(tiled_map, layer_name)
	for index = 1, #tiled_map.layers do
		local layer = tiled_map.layers[index]
		if layer.name == layer_name then
			return detiled_internal.get_property_value(layer.properties, "exclude") or false
		end
	end

	return false
end


---@param object detiled.map.object
---@param tile detiled.tileset.tile|nil
---@param map_height number|nil
---@return number, number, number, number
function M.get_defold_position_from_tiled_object(object, tile, map_height)
	map_height = map_height or 0

	-- Get offset from object point in Tiled to Defold assets object
	-- Tiled point in left bottom, Defold - in object center
	-- And add sprite anchor.x for visual correct posing from tiled (In Tiled we pos the image)
	local base_width = tile and tile.imagewidth or object.width
	local base_height = tile and tile.imageheight or object.height
	local scale_x = 1
	local scale_y = 1
	local anchor_x = 0
	local anchor_y = 0

	if base_width > 0 and base_height > 0 then
		scale_x = object.width / base_width
		scale_y = object.height / base_height
	end

	anchor_x = base_width / 2
	anchor_y = base_height / 2

	do -- Search anchor
		-- If object has anchor point, use it instead
		if tile and tile.objectgroup then
			for index = 1, #tile.objectgroup.objects do
				local tile_object = tile.objectgroup.objects[index]
				if tile_object.point then
					anchor_x = tile_object.x
					anchor_y = base_height - tile_object.y
					break
				end
			end
		end
	end

	-- Rotate offset in case of rotated object
	local rotation_rad = math.rad(object.rotation)
	local sin = math.sin(rotation_rad)
	local cos = math.cos(rotation_rad)

	local rotated_offset_x = anchor_x * cos + anchor_y * sin
	local rotated_offset_y = -anchor_x * sin + anchor_y * cos

	rotated_offset_x = rotated_offset_x * scale_x
	rotated_offset_y = rotated_offset_y * scale_y

	local position_x = object.x + rotated_offset_x
	local position_y = map_height - (object.y - rotated_offset_y)

	return position_x, position_y, scale_x, scale_y
end



---@param tiled_map detiled.map
---@return decore.world.instance
function M.create_world_from_tiled_map(tiled_map)
	return {
		entities = M.get_entities(tiled_map),
	}
end


---Split each layer to separate world, return as map of worlds
---@param world_id string
---@param tiled_map detiled.map
---@return table<string, decore.world.instance>
function M.create_worlds_from_tiled_map(world_id, tiled_map)
	local entities = M.get_entities(tiled_map)
	local worlds = {}
	local world_ids = {}

	for index = 1, #entities do
		local entity = entities[index]
		local layer_id = entity.components.layer_id
		local subworld_id = world_id .. "." .. layer_id

		local world = worlds[subworld_id] or {
			entities = {},
			included_worlds = {},
		}
		worlds[subworld_id] = world
		table.insert(world.entities, entity)

		if not M.is_layer_excluded(tiled_map, layer_id) then
			world_ids[subworld_id] = true
		end
	end

	local main_world = worlds[world_id] or {
		entities = {},
		included_worlds = {},
	}
	worlds[world_id] = main_world

	for subworld_id in pairs(world_ids) do
		table.insert(main_world.included_worlds, {
			world_id = subworld_id,
		})
	end

	return worlds
end


---@param tiled_tileset_path string
---@return table<string, entity>
function M.create_entities_from_tiled_tileset(tiled_tileset_path)
	local tileset = detiled_internal.load_json(tiled_tileset_path)
	if not tileset then
		detiled_internal.logger:error("Failed to load tileset", tiled_tileset_path)
		return {}
	end

	detiled_internal.load_tileset(tileset)
	return M.get_decore_entities(tileset)
end


---@param tiled_tileset detiled.tileset
---@return table<string, entity> entities Key is prefab_id
function M.get_decore_entities(tiled_tileset)
	---@type entity[]
	local entities = {}

	local tiles = tiled_tileset.tiles
	for index = 1, #tiles do
		local tile = tiles[index]
		local prefab_id = tile.class
		---@type entity
		local entity = detiled_internal.get_components_property(tile.properties) or {}
		assert(prefab_id, "The class field in entity in tiled tileset should be set")
		entities[prefab_id] = entity
	end

	return entities
end



return M
