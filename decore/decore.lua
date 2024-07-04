local decore_data = require("decore.decore_data")
local decore_internal = require("decore.decore_internal")


---@class decore
local M = {}
local TYPE_TABLE = "table"


---@param logger_instance decore.logger|nil
function M.set_logger(logger_instance)
	decore_internal.logger = logger_instance or decore_internal.empty_logger
end


---@param name string
---@param level string|nil
---@return decore.logger
function M.get_logger(name, level)
	return setmetatable({ name = name, level = level }, { __index = decore_internal.logger })
end


---Add entities pack to decore entities
---If entities pack with same id already loaded, do nothing.
---If the same id is used in different packs, the last one will be used in M.create_entity
---@param entities_data_or_path decore.entities_pack_data|string
---@return boolean
function M.register_entities(entities_data_or_path)
	local entities_pack_data = decore_internal.get_data_if_path(entities_data_or_path)
	if not entities_pack_data then
		return false
	end

	local pack_id = entities_pack_data.pack_id

	if not decore_data.entities[pack_id] then
		decore_data.entities[pack_id] = entities_pack_data.entities

		for prefab_id, entity_data in pairs(entities_pack_data.entities) do
			entity_data.prefab_id = prefab_id
			entity_data.pack_id = pack_id
		end

		table.insert(decore_data.entities_order, pack_id)
	else
		-- Merge entities, if exists - override
		for prefab_id, entity_data in pairs(entities_pack_data.entities) do
			decore_data.entities[pack_id][prefab_id] = entity_data

			entity_data.prefab_id = prefab_id
			entity_data.pack_id = pack_id
		end
	end

	decore_internal.logger:debug("Registered entities pack id", pack_id)
	return true
end


---Unload entities pack from decore entities
---@param pack_id string
function M.unregister_entities(pack_id)
	if not decore_data.entities[pack_id] then
		decore_internal.logger:warn("No entities pack with id to unload", pack_id)
		return
	end

	decore_data.entities[pack_id] = nil
	decore_internal.remove_by_value(decore_data.entities_order, pack_id)

	decore_internal.logger:debug("Unload entities pack id", pack_id)
end


---Create entity instance from prefab
---@param prefab_id string
---@param pack_id string|nil
---@return entity|nil
function M.create_entity(prefab_id, pack_id)
	for index = #decore_data.entities_order, 1, -1 do
		local check_pack_id = decore_data.entities_order[index]
		local entities_pack = decore_data.entities[check_pack_id]

		local prefab = entities_pack[prefab_id]
		if prefab and (not pack_id or pack_id == check_pack_id) then
			local entity = {}

			for component_id, prefab_data in pairs(prefab) do
				M.apply_component(entity, component_id, prefab_data)
			end

			return entity
		end
	end

	decore_internal.logger:error("No entity with id", {
		prefab_id = prefab_id,
		pack_id = pack_id,
	})

	return nil
end


---Register component to decore components
---@param component_id string
---@param component_data any
---@param pack_id string
function M.register_component(component_id, component_data, pack_id)
	if not decore_data.components[pack_id] then
		decore_data.components[pack_id] = {}
		table.insert(decore_data.components_order, pack_id)
	end

	decore_data.components[pack_id][component_id] = component_data
end


---Register components pack to decore components
---@param components_data_or_path decore.components_pack_data|string
---@return boolean
function M.register_components(components_data_or_path)
	local components_pack_data = decore_internal.get_data_if_path(components_data_or_path)
	if not components_pack_data then
		return false
	end

	local pack_id = components_pack_data.pack_id

	if not decore_data.components[pack_id] then
		decore_data.components[pack_id] = components_pack_data.components
		table.insert(decore_data.components_order, pack_id)
	else
		-- Merge components, if exists - override
		for component_id, component_data in pairs(components_pack_data.components) do
			decore_data.components[pack_id][component_id] = component_data
		end
	end

	decore_internal.logger:debug("Registered components pack id", pack_id)
	return true
end


---@param pack_id string
function M.unregister_components(pack_id)
	if not decore_data.components[pack_id] then
		decore_internal.logger:warn("No components pack with id to unload", pack_id)
		return
	end

	decore_data.components[pack_id] = nil
	decore_internal.remove_by_value(decore_data.components_order, pack_id)

	decore_internal.logger:debug("Unload components pack id", pack_id)
end


---@param component_id string
---@param component_pack_id string|nil
---@return any
function M.create_component(component_id, component_pack_id)
	for index = #decore_data.components_order, 1, -1 do
		local pack_id = decore_data.components_order[index]
		local components_pack = decore_data.components[pack_id]
		local prefab = components_pack[component_id]

		if prefab ~= nil and (not component_pack_id or component_pack_id == pack_id) then
			if type(prefab) == TYPE_TABLE then
				return sys.deserialize(sys.serialize(prefab))
			else
				return prefab
			end
		end
	end

	decore_internal.logger:error("No component with id", {
		component_id = component_id,
		component_pack_id = component_pack_id
	})

	return nil
end


---Add component to entity.
---If component not exists, it will be created with default values
---If component already exists, it will be merged with the new data
---To refresh system filters, call world:addEntity(entity) after this function
---@param entity entity
---@param component_id string
---@param component_data any
---@return entity
function M.apply_component(entity, component_id, component_data)
	if not entity[component_id] then
		-- Create default component with default values if not exists
		entity[component_id] = M.create_component(component_id)
	end

	if type(component_data) == TYPE_TABLE then
		decore_internal.merge_tables(entity[component_id], component_data)
	else
		entity[component_id] = component_data
	end

	return entity
end


---Add components to entity
---To refresh system filters, call world:addEntity(entity) after this function
---@param entity entity
---@param components table<string, any>
---@return entity
function M.apply_components(entity, components)
	for component_id, component_data in pairs(components) do
		M.apply_component(entity, component_id, component_data)
	end

	return entity
end


---@param world_data_or_path decore.worlds_pack_data|string
---@return boolean, string|nil
function M.register_worlds(world_data_or_path)
	local world_pack_data = decore_internal.get_data_if_path(world_data_or_path)
	if not world_pack_data then
		return false
	end

	local pack_id = world_pack_data.pack_id

	if decore_data.worlds[pack_id] then
		decore_internal.logger:info("The world pack with the same id already loaded", pack_id)
		return false, "The world pack with the same id already loaded"
	end

	decore_data.worlds[pack_id] = world_pack_data.worlds
	table.insert(decore_data.worlds_order, pack_id)

	decore_internal.logger:debug("Load worlds pack id", pack_id)

	return true
end


---@param pack_id string
function M.unregister_worlds(pack_id)
	if not decore_data.worlds[pack_id] then
		decore_internal.logger:warn("No worlds pack with id to unload", pack_id)
		return
	end

	decore_data.worlds[pack_id] = nil
	decore_internal.remove_by_value(decore_data.worlds_order, pack_id)

	decore_internal.logger:debug("Unload worlds pack id", pack_id)
end


---Create entity instances from world prefab
---@param world_id string
---@param world_pack_id string|nil @if nil, use first found from latest loaded pack
---@return entity[]|nil
function M.create_world(world_id, world_pack_id)
	for index = #decore_data.worlds_order, 1, -1 do
		local pack_id = decore_data.worlds_order[index]
		local worlds_pack = decore_data.worlds[pack_id]

		local prefab = worlds_pack[world_id]
		if worlds_pack[world_id] and (not world_pack_id or (world_pack_id == pack_id)) then
			local entities = {}

			-- Create all template entities
			if prefab.included_worlds then
				for world_index = 1, #prefab.included_worlds do
					local world_instance = prefab.included_worlds[world_index]
					local world_entities = M.create_world(world_instance.world_id, world_instance.pack_id)
					if world_entities then
						for _, entity in ipairs(world_entities) do
							table.insert(entities, entity)
						end
					end
				end
			end

			if prefab.entities then
				for entity_index = 1, #prefab.entities do
					local entity_info = prefab.entities[entity_index]

					local entity
					if entity_info.prefab_id and entity_info.prefab_id ~= "" then
						-- Create entity from decore entities
						entity = M.create_entity(entity_info.prefab_id, entity_info.pack_id)
					else
						-- Create empty entity
						entity = {}
					end

					if entity then
						local components = entity_info.components
						if components then
							M.apply_components(entity, components)
						end

						table.insert(entities, entity)
					end
				end
			end

			return entities
		end
	end

	decore_internal.logger:error("No world with id", {
		world_id = world_id,
		world_pack_id = world_pack_id,
	})

	return nil
end


---@param world world
---@param world_id string
---@param world_pack_id string|nil
---@param offset_x number|nil
---@param offset_y number|nil
function M.spawn_world(world, world_id, world_pack_id, offset_x, offset_y)
	local entities = M.create_world(world_id, world_pack_id)
	if not entities then
		return
	end

	offset_x = offset_x or 0
	offset_y = offset_y or 0

	for index = 1, #entities do
		local new_entity = entities[index]

		if new_entity.transform then
			new_entity.transform.position_x = new_entity.transform.position_x + offset_x
			new_entity.transform.position_y = new_entity.transform.position_y + offset_y
		end

		world:addEntity(new_entity)
	end
end


---@param world world
---@param id number
---@return entity|nil
function M.get_entity_by_id(world, id)
	return decore_internal.find_entities_by_component_value(world, "id", id)[1]
end


---Return all entities with component name equal to entity_name
---@param world world
---@param entity_name string
---@return entity[]
function M.get_entities_with_name(world, entity_name)
	return decore_internal.find_entities_by_component_value(world, "name", entity_name)
end


---Return all entities with component tiled_id equal to entity_name
---@param world world
---@param tiled_id number
---@return entity[]
function M.get_entities_with_tiled_id(world, tiled_id)
	return decore_internal.find_entities_by_component_value(world, "tiled_id", tiled_id)
end


---Return all entities which is instance of prefab_id
---It should have a prefab_id component with value equal to prefab_id
---@param world world
---@param prefab_id string
---@return entity[]
function M.get_entities_by_prefab_id(world, prefab_id)
	return decore_internal.find_entities_by_component_value(world, "prefab_id", prefab_id)
end


---Log all loaded packs for entities, components and worlds
function M.print_loaded_packs_debug_info()
	decore_internal.logger:debug("Entities packs:")
	for _, pack_id in ipairs(decore_data.entities_order) do
		decore_internal.logger:debug(" - " .. pack_id)
		for prefab_id, _ in pairs(decore_data.entities[pack_id]) do
			decore_internal.logger:debug("   - " .. prefab_id)
		end
	end

	decore_internal.logger:debug("Components packs:")
	for _, pack_id in ipairs(decore_data.components_order) do
		decore_internal.logger:debug(" - " .. pack_id)
		for component_id, _ in pairs(decore_data.components[pack_id]) do
			decore_internal.logger:debug("   - " .. component_id)
		end
	end

	decore_internal.logger:debug("Worlds packs:")
	for _, pack_id in ipairs(decore_data.worlds_order) do
		decore_internal.logger:debug(" - " .. pack_id)
		for world_id, _ in pairs(decore_data.worlds[pack_id]) do
			decore_internal.logger:debug("   - " .. world_id)
		end
	end
end


return M
