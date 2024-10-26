local LOADED_TILESETS = {}

local M = {}

local TYPE_TABLE = "table"
local EMPTY_FUNCTION = function(self, message, context) end

---@class detiled.logger
---@field trace fun(self: detiled.logger, message: string, context: any)
---@field debug fun(self: detiled.logger, message: string, context: any)
---@field info fun(self: detiled.logger, message: string, context: any)
---@field warn fun(self: detiled.logger, message: string, context: any)
---@field error fun(self: detiled.logger, message: string, context: any)

---@type detiled.logger|nil
M.logger = {
	trace = EMPTY_FUNCTION,
	debug = EMPTY_FUNCTION,
	info = EMPTY_FUNCTION,
	warn = EMPTY_FUNCTION,
	error = EMPTY_FUNCTION,
}

M.empty_logger = {
	trace = EMPTY_FUNCTION,
	debug = EMPTY_FUNCTION,
	info = EMPTY_FUNCTION,
	warn = EMPTY_FUNCTION,
	error = EMPTY_FUNCTION,
}


---Split string by separator
---@param s string
---@param sep string
function M.split(s, sep)
	sep = sep or "%s"
	local t = {}
	local i = 1
	for str in string.gmatch(s, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end


---Check if table contains value
---@param t table
---@param value any
---@return boolean
function M.contains(t, value)
	for index = 1, #t do
		if t[index] == value then
			return true
		end
	end

	return false
end


---Create a copy of lua table
---@param orig table The table to copy
---@return table
function M.deepcopy(orig)
	local copy = orig
	if type(orig) == "table" then
		-- It's faster than copying or JSON serialization
		return sys.deserialize(sys.serialize(orig))
	end

	return copy
end


---Load JSON file from game resources folder (by relative path to game.project)
---Return nil if file not found or error
---@param json_path string
---@return table|nil
function M.load_json(json_path)
	local resource, is_error = sys.load_resource(json_path)
	if is_error or not resource then
		return nil
	end

	return json.decode(resource)
end


---@generic T
---@param config_or_path T|table|string
---@return T|table|nil
function M.load_config(config_or_path)
	if type(config_or_path) == "string" then
		local entities_path = config_or_path --[[@as string]]
		local entities_data = M.load_json(entities_path)
		if not entities_data then
			M.logger:error("Can't load config at path", config_or_path)
			return nil
		end

		return entities_data
	end

	return config_or_path --[[@as table]]
end


-- Get the filename (image) when given a complete path
function M.get_filename(path)
	local parts = M.split(path, "/")
	local name = parts[#parts]
	local basename = M.split(name, ".")[1]
	return basename
end


-- Get the filename (image) when given a complete path
function M.get_extname(path)
	local parts = M.split(path, "/")
	local name = parts[#parts]
	local basename = M.split(name, ".")[2]
	return basename
end


---@param source string
---@return detiled.tileset|nil
function M.get_tileset_by_source(source)
	local tileset_name = M.get_filename(source)

	if LOADED_TILESETS[tileset_name] then
		return LOADED_TILESETS[tileset_name]
	end

	return nil
end


---@param game_project_field_id string @field id from game.project with resource path to json
---@param callback fun(file_data: table) @callback function with file data
function M.split_json_resources(game_project_field_id, callback)
	local json_path = sys.get_config_string(game_project_field_id, "")
	if json_path == "" then
		return
	end

	local paths = M.split(json_path, ",")
	for index = 1, #paths do
		local path = paths[index]
		local data = M.load_json(path)
		if data then
			callback(data)
		end
	end
end


---@param tileset detiled.tileset
function M.load_tileset(tileset)
	if LOADED_TILESETS[tileset.name] then
		return LOADED_TILESETS[tileset.name]
	end

	LOADED_TILESETS[tileset.name] = tileset

	return true
end


---@param map detiled.map
---@param tile_global_id number
---@return detiled.tileset.tile|nil, detiled.tileset|nil
function M.get_tile_by_gid(map, tile_global_id)
	-- TODO: is always tilesest goes in sorted order?
	for tileset_index = #map.tilesets, 1, -1 do
		local tileset = map.tilesets[tileset_index]
		local first_gid = tileset.firstgid
		if tile_global_id >= first_gid then
			local tile_id = tile_global_id - first_gid

			local tileset_data = M.get_tileset_by_source(tileset.source)
			if not tileset_data then
				M.logger:error("Tileset not found", tileset.source)
				return nil, nil
			end

			local tile = nil
			for index = 1, #tileset_data.tiles do
				if tileset_data.tiles[index].id == tile_id then
					tile = tileset_data.tiles[index]
					break
				end
			end

			return tile, tileset_data
		end
	end

	return nil
end


---@param properties detiled.map.property[]
---@param property_name string
---@return any|nil
function M.get_property_value(properties, property_name)
	if not properties then
		return nil
	end

	for index = 1, #properties do
		local property = properties[index]
		if property.name == property_name then
			return property.value
		end
	end

	return nil
end


---@param components detiled.map.property[]|nil
---@return table|nil
function M.get_components_property(components)
	if not components then
		return nil
	end

	local parsed_components = {}

	for index = 1, #components do
		local component = components[index]
		if component.propertytype == component.name then
			-- It's a component
			parsed_components[component.name] = component.value
		end

		if not component.propertytype then
			-- It's a property
			parsed_components[component.name] = component.value
		end
	end

	return parsed_components
end


--- Merge one table into another recursively
---@param t1 table
---@param t2 any
function M.merge_tables(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" and type(t1[k]) == "table" then
			M.merge_tables(t1[k], v)
		else
			t1[k] = v
		end
	end
end


---@param entity entity
---@param components table<string, any>
function M.apply_components(entity, components)
	for component_id, component_data in pairs(components) do
		if type(component_data) == TYPE_TABLE then
			entity[component_id] = entity[component_id] or {}
			M.merge_tables(entity[component_id], component_data)
		else
			entity[component_id] = component_data
		end
	end
end


return M
